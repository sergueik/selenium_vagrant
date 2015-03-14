default['wrapper_hostsfile']['sut_hosts'] = {
 '172.26.5.51' =>   %w/www.carnival.com
                       origin-www.carnival.com/,
 '172.26.5.56' =>   'www.carnival.co.uk'
}

# third-party hostnames
default['wrapper_hostsfile']['loopback_hostnames'] = %w/
    metrics.carnival.com
    smetrics.carnival.com
    metrics.carnival.co.uk
    smetrics.carnival.co.uk
    static.ak.facebook.com
    s-static.ak.facebook.com
    ad.doubleclick.net
    ad.yieldmanager.com
    pc1.yumenetworks.com
    fbstatic-a.akamaihd.net
    ad.amgdgt.com
  /
default['wrapper_hostsfile']['append_rest_to_first'] =  false
