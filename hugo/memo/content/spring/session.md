### * `JWS`
- JSON Web Signature(JWS): 텍스트와 같은 content, JSON, 바이너리 데이터를 디지털 서명(RSA, EC or EdDSA) 또는 해시 기반 메시지 인증코드(HMAC)를 사용하여 보호합니다.
- JWS 는 HMAC, RSA, EC, EdDSA, Ed25519(RFC 8037) 를 암호화한 것입니다.


### * `redis`
#### cli 명령어
```
$ flushdb
$ flushall
$ dbsize
$ set key_name value ex 6 # expire after 6 seconds
$ set key_name value px 6000 # expire after 6000 milliseconds
$ keys *
$ get key_name
$ ttl key_name

# ---
$ keys *
1) "smpl.develop.net:sessions:e6b8e822-1718-4d60-9339-5624be250155"

$ hgetall "smpl.develop.net:sessions:e6b8e822-1718-4d60-9339-5624be250155"
1) "maxInactiveInterval"
2) "\xac\xed\x00\x05sr\x00\x11java.lang.Integer\x12\xe2\xa0\xa4\xf7\x81\x878\x02\x00\x01I\x00\x05valuexr\x00\x10java.lang.Number\x86\xac\x95\x1d\x0b\x94\xe0\x8b\x02\x00\x00xp\x00\x00\a\b"
3) "creationTime"
4) "\xac\xed\x00\x05sr\x00\x0ejava.lang.Long;\x8b\xe4\x90\xcc\x8f#\xdf\x02\x00\x01J\x00\x05valuexr\x00\x10java.lang.Number\x86\xac\x95\x1d\x0b\x94\xe0\x8b\x02\x00\x00xp\x00\x00\x01\x8c\xcaSz<"
5) "sessionAttr:user"
6) "\xac\xed\x00\x05sr\x00\x1cspring.framework.common.User\xfc\xfe\xaa`\x9f\x84L\xae\x02\x00\x03L\x00\x02idt\x00\x12Ljava/lang/String;L\x00\x04nameq\x00~\x00\x01L\x00\x06passwdq\x00~\x00\x01xpt\x00\x04x123t\x00\x03aaap"
7) "lastAccessedTime"
8) "\xac\xed\x00\x05sr\x00\x0ejava.lang.Long;\x8b\xe4\x90\xcc\x8f#\xdf\x02\x00\x01J\x00\x05valuexr\x00\x10java.lang.Number\x86\xac\x95\x1d\x0b\x94\xe0\x8b\x02\x00\x00xp\x00\x00\x01\x8c\xca\\Q\xf3"

$ 
```
