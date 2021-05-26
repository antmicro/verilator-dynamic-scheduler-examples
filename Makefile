VERILATOR_SRC=verilator

EXAMPLE_PREFIX=Vtop

VERILATOR_DEST=${PWD}
VERILATOR_BIN=${VERILATOR_DEST}/bin/verilator
VERILATOR_FLAGS=--output-split-cfuncs 1 -Wno-WIDTH --prefix ${EXAMPLE_PREFIX} -o ${EXAMPLE_PREFIX} --exe

BUILD_DIR=${PWD}/build
EXAMPLES_DIR=${PWD}/examples

%: ${BUILD_DIR}/%
	@echo -e "\033[1;34m\033[1m +------------------------------+\033[0m"
	@echo -e "\033[1;34m\033[1m |      Running simulation      |\033[0m"
	@echo -e "\033[1;34m\033[1m +------------------------------+\033[0m"
	@${BUILD_DIR}/$@/${EXAMPLE_PREFIX}

${BUILD_DIR}/%: | ${VERILATOR_BIN}
	@mkdir -p ${BUILD_DIR}
	${VERILATOR_BIN} ${VERILATOR_FLAGS} --Mdir ${BUILD_DIR}/$* --cc $^
	${MAKE} -C ${BUILD_DIR}/$* -f ${EXAMPLE_PREFIX}.mk

${VERILATOR_BIN}:
	@cd ${VERILATOR_SRC} && autoconf && ./configure --prefix ${VERILATOR_DEST}
	@${MAKE} -C ${VERILATOR_SRC} install

clean:
	rm -rf ${VERILATOR_DEST}/{bin,share}
	rm -rf ${BUILD_DIR}
	-@${MAKE} -C ${VERILATOR_SRC} clean

${BUILD_DIR}/uart: ${EXAMPLES_DIR}/uart/main.cpp ${EXAMPLES_DIR}/uart/tb.sv ${wildcard ${EXAMPLES_DIR}/uart/verilog-uart/rtl/uart*}
${BUILD_DIR}/clock: ${EXAMPLES_DIR}/clock/main.cpp ${EXAMPLES_DIR}/clock/clock.sv
${BUILD_DIR}/events: ${EXAMPLES_DIR}/events/main.cpp ${EXAMPLES_DIR}/events/events.sv
${BUILD_DIR}/fork: ${EXAMPLES_DIR}/fork/main.cpp ${EXAMPLES_DIR}/fork/fork.sv
${BUILD_DIR}/pong: ${EXAMPLES_DIR}/pong/main.cpp ${EXAMPLES_DIR}/pong/pong.sv
${BUILD_DIR}/randomize: ${EXAMPLES_DIR}/randomize/main.cpp ${EXAMPLES_DIR}/randomize/randomize.sv
${BUILD_DIR}/wait: ${EXAMPLES_DIR}/wait/main.cpp ${EXAMPLES_DIR}/wait/wait.sv
