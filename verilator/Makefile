
.PHONY: run

CFLAGS := $(shell pkg-config sdl2 --cflags)
LDFLAGS := $(shell pkg-config sdl2 --libs)

run:
	rm -rf ./obj_dir
	verilator -Wall -Wno-fatal --cc ../CoCo2.sv -y ../ -y MiSTer -y ../rtl --exe tb.cpp -CFLAGS '${CFLAGS} -g' -LDFLAGS '${LDFLAGS}' run.vlt
	make -j -C ./obj_dir -f VCoCo2.mk VCoCo2
	# when running on termux:
	cp -R obj_dir ~

trace:
	rm -rf ./obj_dir
	verilator -Wall -Wno-fatal --cc ../CoCo2.sv -y ../ -y MiSTer -y ../rtl --exe tb.cpp --trace -CFLAGS '${CFLAGS} -g' -LDFLAGS '${LDFLAGS}' trace.vlt
	make -j -C ./obj_dir -f VCoCo2.mk VCoCo2
	# when running on termux:
	cp -R obj_dir ~

