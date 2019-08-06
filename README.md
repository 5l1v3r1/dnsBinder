# DESCRIPTION 
Get the DNS server version using chaos class.
In addition, it tries to get the hostname, id and authors list

# USAGE
- Syntaxe:
   - dnsBinder.sh [-d|--domain|--domaine] dns_server [-o|--output|--sortie output_file]
- Examples
   - dnsBinder.sh -d "ns01.example.com"
   - dnsBinder.sh --domain "ns01.example.com"
   - dnsBinder.sh --domaine "ns01.example.com"
   - dnsBinder.sh -d "ns01.example.com" -o dns_example_information.txt
   - dnsBinder.sh -d "ns01.example.com" --output dns_example_information.txt
   - dnsBinder.sh -d "ns01.example.com" --sortie dns_example_information.txt

# STANDARD OUTPUT EXAMPLE

- ■ DNS Server: ns04.example.com
- ■ Output file: analyse/test.txt

- ■ VERSION.BIND: 
-  ├─■ NSLookUp: 9.10.3-P4-Ubuntu
-  └─■ DIG: 9.10.3-P4-Ubuntu

- ■ AUTHORS.BIND: 
-  └─■ DIG: 
-    ├─¤ Person 1
-    ├─¤ Person 2
-    ├─¤ ...
-    ├─¤ Person N
-    └─■ Total: N
- 
- ■ HOSTNAME.BIND: 
-  └─■ DIG: hostname001

- ■ ID.BIND: 
-  └─■ DIG: Aucune réponse/No response

# ABOUT
- Verison: 0.9 Beta
- Created: 06/08/2019
- Updated: 06/08/2019
