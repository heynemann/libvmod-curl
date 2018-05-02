vcl 4.0;

import curl from "/app/src/.libs/libvmod_curl.so";

backend default {
    .host = "http";
    .port = "8083";
}

sub vcl_init {
    curl.set_pool_size(1000);
}

sub vcl_recv {
    curl.get("http://http:8083");
    if (!curl.error()) {
        set req.http.X-Curl-Status = curl.status();
    } else {
        set req.http.X-Curl-Status = "500";
    }
}

sub vcl_deliver {
    set resp.http.X-Curl-Status = req.http.X-Curl-Status;
}
