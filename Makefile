VERILATOR_SRC=verilator
UART_SRC=verilog-uart/rtl

EXAMPLE_FILES=testbench.sv ${UART_SRC}/uart* ${PWD}/cpp.cpp
EXAMPLE_PREFIX=Vtop

VERILATOR_DEST=${PWD}
VERILATOR_BIN=${VERILATOR_DEST}/bin/verilator
VERILATOR_FLAGS=--output-split-cfuncs 1 -Wno-WIDTH --prefix ${EXAMPLE_PREFIX} -o ${EXAMPLE_PREFIX} --exe

BUILD_DIR=build

uart: ${VERILATOR_BIN}
	@mkdir -p ${BUILD_DIR}
	${VERILATOR_BIN} ${VERILATOR_FLAGS} --Mdir ${BUILD_DIR}/$@ --cc ${EXAMPLE_FILES}
	${MAKE} -C ${BUILD_DIR}/$@ -f ${EXAMPLE_PREFIX}.mk
	@echo -e "\033[1;34m\033[1m +------------------------------+\033[0m"
	@echo -e "\033[1;34m\033[1m |      Running simulation      |\033[0m"
	@echo -e "\033[1;34m\033[1m +------------------------------+\033[0m"
	@${BUILD_DIR}/$@/${EXAMPLE_PREFIX}

${VERILATOR_BIN}:
	@cd ${VERILATOR_SRC} && autoconf && ./configure --prefix ${VERILATOR_DEST}
	@${MAKE} -C ${VERILATOR_SRC} install

clean:
	@${MAKE} -C ${VERILATOR_SRC} clean
	rm -rf ${VERILATOR_DEST}/{bin,share}
	rm -rf ${BUILD_DIR}
