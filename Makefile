OUT_DIR="${HOME}/.panamax"

install:
	mkdir -p $(OUT_DIR)
	cp -Ra . $(OUT_DIR)

clean:
	rm -rf $(OUT_DIR)