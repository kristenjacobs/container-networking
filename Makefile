SUBDIRS := 1-network-namespace 2-single-node 3-multi-node 4-overlay-network

.PHONY: vagrant-up vagrant-destroy vagrant-status test $(SUBDIRS)

vagrant-up:
	for d in $(SUBDIRS); do \
	    cd $$d && vagrant up && cd ../ ; \
	done

vagrant-status: $(SUBDIRS)
	for d in $(SUBDIRS); do \
	    cd $$d && vagrant status && cd ../ ; \
	done

test: $(SUBDIRS)
	for d in $(SUBDIRS); do \
	    cd $$d && make && cd ../ ; \
	done

vagrant-destroy: $(SUBDIRS)
	for d in $(SUBDIRS); do \
	    cd $$d && vagrant destroy --force && cd ../ ; \
	done

clean: $(SUBDIRS)
	for d in $(SUBDIRS); do \
	    cd $$d && make clean && cd ../ ; \
	done
