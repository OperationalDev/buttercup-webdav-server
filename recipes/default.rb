#
# Cookbook:: buttercup-webdav-server
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright:: 2018, Marcus Talken
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

include_recipe 'acme'

node.override['acme']['contact'] = ['mailto:operationaldev@gmail.com']
# Real certificates please...
node.override['acme']['endpoint'] = 'https://acme-v01.api.letsencrypt.org'


# Generate selfsigned certificate so nginx can start

acme_selfsigned 'temp.automatron.co.za' do
  crt     '/etc/ssl/temp.automatron.co.za.crt'
  key     '/etc/ssl/temp.automatron.co.za.key'
end

package 'nginx'

package 'nginx-extras'

package 'apache2-utils'

template '/etc/nginx/sites-enabled/webdav' do
  source 'webdav.erb'
  notifies :restart, 'service[nginx]', :delayed
end

service 'nginx' do
  action [ :enable, :start ]
end

acme_certificate 'bcpw-host.automatron.co.za' do
  alt_names         ['bcpw.automatron.co.za']
  crt               '/etc/ssl/bcpw-host.automatron.co.za.crt'
  key               '/etc/ssl/bcpw-host.automatron.co.za.key'
  wwwroot           '/var/webdav'
  notifies          :reload, 'service[nginx]'
end
