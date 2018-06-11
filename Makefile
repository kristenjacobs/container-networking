SUBDIRS := 1-network-namespace 2-single-node 3-multi-node 4-overlay-network

.PHONY: vagrant-up vagrant-destroy $(SUBDIRS)

vagrant-up:
	for d in $(SUBDIRS); do \
	    cd $$d && vagrant up && cd ../ ; \
	done

vagrant-destroy: $(SUBDIRS)
	for d in $(SUBDIRS); do \
	    cd $$d && vagrant destroy --force && cd ../ ; \
	done
