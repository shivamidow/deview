LLVM_BUILD ?= /home/chenxiong/11vm/build/
Devirt_DIR := ${CURDIR}/src
Devirt_BUILD := ${CURDIR}/build

NPROC := ${shell nproc}

build_codedep_func = \
	(mkdir -p ${2} \
		&& cd ${2} \
		&& PATH=${LLVM_BUILD}/bin:${PATH} \
			LLVM_ROOT_DIR=${LLVM_BUILD}/bin \
			LLVM_LIBRARY_DIRS=${LLVM_BUILD}/lib \
			LLVM_INCLUDE_DIRS=${LLVM_BUILD}/include \
			CC=gcc CXX=g++ \
            cmake ${1} -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_CXX_FLAGS_RELEASE="-std=c++14 -fno-rtti -Ofast -fomit-frame-pointer -UNDEBUG_ENABLE -flto -free" \
		&& make -j${NPROC})


all: codedep

codedep:
	$(call build_codedep_func, ${Devirt_DIR}, ${Devirt_BUILD})

