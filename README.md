# gns3Aulas
Arquivos e script para configuração da VM do GNS3 para as aulas de Redes de Computadores e Cibersegurança da UTFPR de Campo Mourão.

Esse script configura a VM do GNS3 incluindo/configurando todos os recursos necessários para as aulas de Redes de Computadores e Cibersegurança, o que inclui: Dockers representando hosts cliente e roteador Linux, bem como os roteadores Cisco 7200 e 3640 (sendo que este último é utilizado como switch).

## Instalação

Tudo inicia baixando a VM do GNS3 em <https://www.gns3.com/software/download-vm>. Depois de acessar tal VM via ``SSH -Y``, execute os passos/comandos a seguir:


1. Clone o projeto ou faça o _download_:

```console
$ git clone https://github.com/luizsantos/gns3Aulas
```

2. Entre no diretório do projeto:

```console
$ cd gns3Aulas
```

3. Execute o script:

```console
$ sh install.sh
```

ou

```console
$ ./install.sh
```

4. Após isso responda as perguntas do script, que basicamente são:
* Instalar appliances/templates no GNS3?
> Os appliances são:
> i. um host Linux para simular clientes de rede no modo texto - é um docker;
> ii. um roteador Linux (com o Quagga); iii. um roteador Cisco 7200;
> iv. um switch Camada 3 Cisco 3640 (estou usando esse como switch, pois o GNS3 tem problemas com switchs Cisco L2, mas ele é também um roteador - não quero usar o qemu);
* Instalar o GNS3-gui, para acessar o GNS3 com uma interface gráfica desktop, via X11/SSH?
* Instalar o Cisco Packet Tracer para usar via X11/SSH? (útil para alunos que não têm problemas em instalar o Cisco Packet Tracer - assim temos dois simuladores na mesma VM).


