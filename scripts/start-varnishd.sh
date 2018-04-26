#!/bin/bash
exec varnishd -j unix,user=varnishd -F -f ${VARNISH_VCL_PATH} -s malloc,${VARNISH_MEMORY} -a 0.0.0.0:${VARNISH_PORT} -p http_req_hdr_len=16384 -p http_resp_hdr_len=16384 ${VARNISH_DAEMON_OPTS}
