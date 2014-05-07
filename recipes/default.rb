include_recipe 'balanced-apt'
include_recipe 'balanced-postgresql'
include_recipe 'balanced-postgresql::server'
include_recipe 'balanced-postgresql::client'

include_recipe 'python'
include_recipe 'git'

package 'libzmq-dev'

directory '/srv' do
  action :create
end

git '/srv/benchmark' do
  repository 'https://github.com/balanced/aggregation-benchmark.git'
  action :sync
end

python_virtualenv '/srv/benchmark/.env' do
  action :create
end

python_pip 'psycopg2' do
  virtualenv '/srv/benchmark/.env'
end

bash 'install-benchmark' do
  code <<-EOF
  	cd /srv/benchmark
  	.env/bin/pip install .
  EOF
end

pg_user 'benchmark' do
  privileges superuser: true, createdb: true, login: true
  password 'benchmark'
end

pg_database 'benchmark' do
  owner 'benchmark'
end

template '/opt/benchmark.sh' do
  source 'benchmark.sh.erb'
  mode '755'
end
