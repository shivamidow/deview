const fs = require('fs');
const os = require('os');
const path = require('path');
const puppeteer = require('puppeteer');
const yargs = require('yargs');

const gremlinsJS = fs.readFileSync('gremlins.js', 'utf8');

const DEFAULT_PUPPETEER_ARGS = [
  '--disable-background-networking',
  '--enable-features=NetworkService,NetworkServiceInProcess',
  '--disable-background-timer-throttling',
  '--disable-backgrounding-occluded-windows',
  '--disable-breakpad',
  '--disable-client-side-phishing-detection',
  '--disable-component-extensions-with-background-pages',
  '--disable-default-apps',
  '--disable-dev-shm-usage',
  '--disable-features=TranslateUI',
  '--disable-hang-monitor',
  '--disable-ipc-flooding-protection',
  '--disable-popup-blocking',
  '--disable-prompt-on-repost',
  '--disable-renderer-backgrounding',
  '--disable-sync',
  '--force-color-profile=srgb',
  '--metrics-recording-only',
  '--no-first-run',
  '--enable-automation',
  '--password-store=basic',
  '--use-mock-keychain',
  '--remote-debugging-port=0',
];

function loadPreferences(appId) {
  const prefPath = path.join(os.homedir(), '.config', 'chromium-profiling', 'Default', 'Preferences');
  const prefFile = fs.readFileSync(prefPath);
  return prefFile ? JSON.parse(prefFile) : null;
}

(async () => {
  const args = yargs
    .command('$0 [file]', 'run profiling with a test file', {
      file: {
        describe: 'an absolute file path to run for profiling',
        type: 'string'
      }
    })
    .option('app-id', {
      description: 'App ID of the target pwa',
      type: 'string',
    })
    .option('wait-for', {
      description: 'miliseconds to wait after input events',
      type: 'number',
    })
    .help()
    .alias('help', 'h')
    .argv;

  if (!args.appId)
    return;

  const appId = args.appId;
  const timeToWait = args.waitFor ? args.waitFor : 30000;
  const crPath = path.join(path.dirname(__filename), '..', 'chromium', 'src', 'out', 'profiling', 'chrome');
  if (!fs.existsSync(crPath)) {
    console.log('Either chrome binary does not exist! You should build chromium in this repository first.');
    return;
  }

  const prefs = loadPreferences(appId);
  if (!prefs)
    return;

  const browserArgs = [
    `--app-id=${appId}`,
    '--profile-directory=Default',
    '--user-data-dir=',
    '--incognito',
    // Headless options
//    '--headless',
//    '--hide-scrollbars',
//    '--mute-audio',
  ];
  browserArgs.push(...DEFAULT_PUPPETEER_ARGS);

  const browser = await puppeteer.launch({
    executablePath: crPath,
    ignoreDefaultArgs: true,
    defaultViewport: null,
    args: browserArgs
  });

  let page = (await browser.pages()).pop();
  if (!page) {
    const context = await browser.createIncognitoBrowserContext();
    page = await context.newPage();
  }

  await Promise.all([
    page.coverage.startJSCoverage(),
    page.coverage.startCSSCoverage()
  ]);

  const homeURL = prefs['extensions']['settings'][appId]['manifest']['app']['launch']['web_url'];
  //const homeURL = 'http://www.smartvoter.org/2006/';
  console.log('Init url', page.url(), '->', homeURL);

  await page.goto(homeURL, {waitUntil: ['load', 'networkidle0']});
  //await page.goto(homeURL, {waitUntil: ['load', 'domcontentloaded']});

  await page.addScriptTag({ content: gremlinsJS });
  await page.evaluate(() => {
    gremlins.createHorde({
      species: [gremlins.species.clicker(), gremlins.species.toucher(), gremlins.species.formFiller(), gremlins.species.scroller(), gremlins.species.typer()],
      mogwais: [gremlins.mogwais.alert(), gremlins.mogwais.gizmo({ maxErrors: 100000 })],
      strategies: [gremlins.strategies.distribution({ nb: 1000000})]
    }).unleash();
  });

  await page.waitFor(timeToWait);

  const [jsCoverage, cssCoverage] = await Promise.all([
    page.coverage.stopJSCoverage(),
    page.coverage.stopCSSCoverage()
  ]);

  const js_coverage = [...jsCoverage];
  const css_coverage = [...cssCoverage];

  let coverage = "";
  let js_used_bytes = 0;
  let js_total_bytes = 0;
  let js_sources = {}
  for (const entry of js_coverage) {
    if (entry.url.startsWith('chrome-extension://'))
      continue

    js_total_bytes += entry.text.length;
    if (entry.url in js_sources)
      js_sources[entry.url] += entry.text.length;
    else
      js_sources[entry.url] = entry.text.length;

    for (const range of entry.ranges)
      js_used_bytes += (range.end - range.start - 1);
  }
  coverage += '[JavaScript]\n';
  coverage += `${js_used_bytes}/${js_total_bytes} bytes, ${Object.keys(js_sources).length} files\n`;
  for (let key in js_sources)
    coverage += `${js_sources[key]} ${key}\n`;
  coverage += '\n';
  console.log(`JS: ${js_used_bytes}/${js_total_bytes} bytes, ${Object.keys(js_sources).length} files`);

  let css_used_bytes = 0;
  let css_total_bytes = 0;
  let css_sources = {};
  for (const entry of css_coverage) {
    if (entry.url.startsWith('chrome-extension://'))
      continue
    css_total_bytes += entry.text.length;
    if (entry.url in css_sources)
      css_sources[entry.url] += entry.text.length;
    else
      css_sources[entry.url] = entry.text.length;

    for (const range of entry.ranges)
      css_used_bytes += (range.end - range.start);
  }

  coverage += '[CSS]\n';
  coverage += `${css_used_bytes}/${css_total_bytes} bytes, ${Object.keys(css_sources).length} files\n`;
  for (let key in css_sources)
    coverage += `${css_sources[key]} ${key}\n`;
  console.log(`CSS: ${css_used_bytes}/${css_total_bytes} bytes, ${Object.keys(css_sources).length} files`);
  fs.writeFile("./coverage.txt", coverage, (err) => {
    if (err)
      return console.log(err);
    console.log("The file was saved!");
  });

  await browser.close();
})();
