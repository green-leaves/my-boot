openssl x509 -req -CA rootCA.pem -CAkey rootCA.key -in domain.csr -out domain.crt -days 9999 -CAcreateserial -passin pass:retapp -extfile request.conf -extensions v3_req
