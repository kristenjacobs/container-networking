all: setup test teardown

setup:
	rm -rf setup-1.complete setup-2.complete
	vagrant ssh 4-overlay-network-1 -c 'cd /vagrant ; ./setup.sh > setup-1.log ; touch setup-1.complete' &
	vagrant ssh 4-overlay-network-2 -c 'cd /vagrant ; ./setup.sh > setup-2.log ; touch setup-2.complete' &
	until [ -f setup-1.complete ] && [ -f setup-2.complete ]; do sleep 1; done

test:
	vagrant ssh 4-overlay-network-1 -c 'cd /vagrant ; ./test.sh'
	vagrant ssh 4-overlay-network-2 -c 'cd /vagrant ; ./test.sh'

teardown:
	rm -rf teardown-1.complete teardown-2.complete
	-vagrant ssh 4-overlay-network-1 -c 'cd /vagrant ; ./teardown.sh > teardown-1.log ; touch teardown-1.complete' &
	-vagrant ssh 4-overlay-network-2 -c 'cd /vagrant ; ./teardown.sh > teardown-2.log ; touch teardown-2.complete' &
	until [ -f teardown-1.complete ] && [ -f teardown-2.complete ]; do sleep 1; done

clean:
	rm -rf *.log *.complete

ssh1:
	vagrant ssh 4-overlay-network-1

ssh2:
	vagrant ssh 4-overlay-network-2
