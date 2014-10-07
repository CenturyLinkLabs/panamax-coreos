ROOT_DIR="${HOME}"
OUT_DIR="${ROOT_DIR}/.panamax"
OLD_INSTALL_DIR="${HOME}/.panamax"
PMX_VAR="${HOME}/.panamax"

install:
	mkdir -p $(OUT_DIR)
	cp -Ra . $(OUT_DIR)
	ln -nsf $(OUT_DIR)/panamax /usr/local/bin
ifeq ("$(wildcard $(OLD_INSTALL_DIR) )","")
	mkdir -p $(PMX_VAR)
	-mv "$(OLD_INSTALL_DIR)/images.vdi" "$(PMX_VAR)"
	-mv "$(OLD_INSTALL_DIR)/.env" "$(PMX_VAR)"
	rm -rf "$(OLD_INSTALL_DIR)"
endif
clean:
	rm -rf $(OUT_DIR)
