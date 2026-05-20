# PySpark Data Engineering — Dev Container

Ambiente de desenvolvimento completo para Engenharia e Ciência de Dados, baseado em **Apache Spark**, **Python 3.11** e **Jupyter Notebook**, executado em container Docker com integração ao VS Code Dev Containers.

---

## Sumário

- [Pré-requisitos](#pré-requisitos)
- [Configuração do ambiente — WSL + Docker](#configuração-do-ambiente--wsl--docker)
  - [1. Instalar o WSL 2](#1-instalar-o-wsl-2)
  - [2. Limpeza de distros antigas](#2-limpeza-de-distros-antigas-opcional)
  - [3. Instalar Ubuntu no WSL](#3-instalar-ubuntu-no-wsl)
  - [4. Instalar Docker Engine no Ubuntu](#4-instalar-docker-engine-no-ubuntu-sem-docker-desktop)
  - [5. Usar Docker sem sudo](#5-usar-docker-sem-sudo)
  - [6. Testar o Docker](#6-testar-o-docker)
  - [7. Boas práticas no WSL](#7-boas-práticas-no-wsl)
- [Configuração inicial](#configuração-inicial)
- [Subindo o container com Docker](#subindo-o-container-com-docker)
- [Usando com VS Code Dev Containers](#usando-com-vs-code-dev-containers)
- [Variáveis de ambiente](#variáveis-de-ambiente)
- [Stack de ferramentas incluídas](#stack-de-ferramentas-incluídas)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Comandos úteis](#comandos-úteis)
- [Troubleshooting](#troubleshooting)

---

## Pré-requisitos

| Ferramenta | Versão mínima | Link |
|---|---|---|
| Docker Desktop | 4.x | https://www.docker.com/products/docker-desktop |
| WSL 2 (Windows) | — | `wsl --install` no PowerShell como admin |
| VS Code | 1.80+ | https://code.visualstudio.com |
| Extensão Dev Containers | — | ID: `ms-vscode-remote.remote-containers` |

---

## Configuração do ambiente — WSL + Docker

> Esta seção cobre a instalação do zero para Windows. Se já tiver WSL e Docker configurados, pule para [Configuração inicial](#configuração-inicial).

### 1. Instalar o WSL 2

Abra o **PowerShell como Administrador** e verifique se o WSL já está instalado:

```powershell
wsl --status
```
> Exibe a versão do WSL instalada e a distro padrão configurada. Use para confirmar se o ambiente já existe antes de instalar.

Se não estiver instalado:

```powershell
wsl --install
```
> Habilita o WSL 2 no Windows, instala a distro Ubuntu padrão e configura o kernel Linux automaticamente. Requer acesso de administrador.

> Reinicie o Windows quando solicitado para que o kernel do WSL seja carregado corretamente.

---

### 2. Limpeza de distros antigas (opcional)

Caso já tenha uma instalação anterior com problemas ou que queira substituir:

```powershell
wsl --list --verbose
```
> Lista todas as distros Linux instaladas no WSL com nome, estado (Running/Stopped) e versão (1 ou 2). Útil para identificar o que está instalado antes de remover.

```powershell
wsl --shutdown
```
> Encerra todas as distros WSL em execução. Necessário antes de remover uma distro para evitar erros de arquivo em uso.

```powershell
wsl --unregister Ubuntu
```
> Remove completamente a distro informada, apagando todos os arquivos do sistema Linux associados. **Ação irreversível** — faça backup antes se necessário.

---

### 3. Instalar Ubuntu no WSL

```powershell
wsl --install -d Ubuntu-22.04
```
> Instala especificamente o Ubuntu 22.04 LTS no WSL 2. A versão 22.04 é usada por ser LTS (suporte de longo prazo) e compatível com o Docker Engine e as libs deste projeto.

Após a instalação, o terminal pedirá para criar um usuário e senha Linux. Essa senha será usada para qualquer comando `sudo` dentro do Ubuntu.

Para abrir o Ubuntu pelo terminal quando quiser:

```powershell
wsl -d Ubuntu-22.04
```
> Abre o terminal da distro especificada diretamente. Útil quando há múltiplas distros instaladas e você quer garantir que está abrindo a correta.

Dentro do Ubuntu, atualize os pacotes do sistema:

```bash
sudo apt update && sudo apt upgrade -y
```
> `apt update` baixa a lista de pacotes disponíveis nos repositórios. `apt upgrade -y` instala as versões mais recentes de todos os pacotes já instalados. Fazer isso logo após a instalação garante que o sistema está com as últimas correções de segurança.

---

### 4. Instalar Docker Engine no Ubuntu (sem Docker Desktop)

> Este projeto utiliza Docker **nativo no Ubuntu via WSL**, sem depender do Docker Desktop. Essa abordagem é mais leve, estável e dá controle total sobre o daemon.

#### 4.1 Instalar dependências

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```
> Instala ferramentas necessárias para a etapa seguinte: `ca-certificates` valida certificados HTTPS, `curl` faz download de arquivos, `gnupg` verifica assinaturas criptográficas e `lsb-release` informa o codinome da distro (usado na URL do repositório).

#### 4.2 Adicionar a chave GPG oficial do Docker

```bash
sudo mkdir -p /etc/apt/keyrings
```
> Cria o diretório onde ficam armazenadas as chaves GPG de repositórios externos. O `-p` evita erro caso o diretório já exista.

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
> Baixa a chave GPG pública do Docker e a converte para o formato binário (`.gpg`) esperado pelo APT. Essa chave garante que os pacotes instalados são autênticos e não foram adulterados.

#### 4.3 Adicionar o repositório do Docker

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
> Registra o repositório oficial do Docker como fonte de pacotes para o APT. O comando detecta automaticamente a arquitetura (`amd64`, `arm64`) e o codinome da distro (ex: `jammy` para Ubuntu 22.04), garantindo que os pacotes corretos sejam baixados.

#### 4.4 Instalar o Docker

```bash
sudo apt update
```
> Atualiza a lista de pacotes do APT para incluir os do repositório do Docker recém-adicionado.

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```
> Instala o Docker completo: `docker-ce` é o daemon, `docker-ce-cli` é a linha de comando, `containerd.io` gerencia o ciclo de vida dos containers, `docker-buildx-plugin` habilita builds avançados e `docker-compose-plugin` adiciona o comando `docker compose`.

#### 4.5 Iniciar o Docker

```bash
sudo service docker start
```
> Inicia o daemon do Docker. No WSL o serviço não sobe automaticamente com o sistema, então é preciso iniciá-lo manualmente antes de usar qualquer comando Docker.

```bash
sudo service docker status
```
> Verifica se o daemon está ativo (`running`). Confirme isso antes de tentar rodar containers para evitar erros de conexão.

---

### 5. Usar Docker sem sudo

```bash
sudo usermod -aG docker $USER
```
> Adiciona o usuário atual ao grupo `docker`. Por padrão, apenas o root pode se comunicar com o daemon — estar no grupo `docker` concede essa permissão sem precisar de `sudo` em cada comando.

```powershell
wsl --shutdown
```
> Reinicia o WSL para que a alteração de grupo seja aplicada na sessão. Sem reiniciar, o sistema ainda reconhece o usuário com os grupos antigos.

Abra o Ubuntu novamente e teste:

```bash
docker ps
```
> Lista os containers em execução. Se retornar uma tabela vazia (sem erro), o Docker está acessível sem `sudo` e funcionando corretamente.

---

### 6. Testar o Docker

```bash
docker run hello-world
```
> Baixa a imagem `hello-world` do Docker Hub (se não existir localmente), cria um container temporário e exibe uma mensagem de confirmação. É o teste padrão para validar que todo o pipeline — daemon, rede e registro — está operacional.

Se aparecer a mensagem **"Hello from Docker!"**, o ambiente está pronto.

---

### 7. Boas práticas no WSL

```bash
sudo service docker start
```
> Execute este comando sempre que reiniciar o Windows. O WSL não inicia serviços automaticamente no boot, portanto o Docker precisa ser ligado manualmente a cada sessão.

- **Não misture Docker Desktop com Docker nativo** — os dois gerenciam daemons diferentes e podem causar conflitos de socket e versão
- **Mantenha os projetos dentro do filesystem Linux** (`/home/seuUsuario/`) — acessar arquivos do Windows via `/mnt/c/` é significativamente mais lento por causa da camada de tradução entre os dois sistemas de arquivos

---

## Configuração inicial

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd DataEngineering
```

### 2. Crie o arquivo `.env` a partir do exemplo

```bash
cp .env.example .env
```

Edite o `.env` com seus valores:

```env
NB_USER=hexdata
NB_UID=1000
NB_GID=100
JUPYTER_PORT=8888
WORK_DIR=/mnt/c/projeto
```

> **Formato do `WORK_DIR` por sistema operacional:**
>
> | Sistema | Exemplo |
> |---|---|
> | WSL 2 (Windows) | `/mnt/c/projeto` |
> | Linux nativo (Ubuntu/Debian) | `/home/seuUsuario/projeto` |
> | macOS | `/Users/seuUsuario/projeto` |
> | Docker Toolbox (legado) | `/c/Users/seuUsuario/projeto` |

---

## Subindo o container com Docker

### Build da imagem

```bash
# Build completo (necessário na primeira vez ou após editar o Dockerfile)
docker compose build

# Build sem cache (força reinstalação de todas as dependências)
docker compose build --no-cache
```

### Iniciar o container

```bash
# Sobe em background (detached)
docker compose up -d

# Sobe com log em tempo real no terminal
docker compose up
```

Após subir, acesse o Jupyter em: **http://localhost:8888**

### Parar o container

```bash
# Para sem remover o container
docker compose stop

# Para e remove o container (mantém a imagem)
docker compose down

# Para, remove container e volumes anônimos
docker compose down -v
```

### Gerenciar containers manualmente (sem compose)

```bash
# Build manual da imagem
docker build -t pyspark-data-engineering:latest .

# Rodar o container manualmente
docker run -d \
  --name spark-dev \
  -p 8888:8888 \
  -e NB_USER=hexdata \
  -e NB_UID=1000 \
  -e CHOWN_HOME=yes \
  -v /mnt/c/Users/SeuNome/projetos:/home/hexdata/work \
  pyspark-data-engineering:latest \
  start.sh jupyter notebook \
    --NotebookApp.token='' \
    --NotebookApp.ip='0.0.0.0'

# Parar e remover container manual
docker stop spark-dev && docker rm spark-dev
```

### Acessar o terminal do container em execução

```bash
# Via compose (serviço spark)
docker compose exec spark bash

# Via container ID
docker exec -it <container_id> bash
```

### Ver logs do container

```bash
# Logs em tempo real via compose
docker compose logs -f spark

# Últimas 100 linhas
docker compose logs --tail=100 spark
```

---

## Usando com VS Code Dev Containers

1. Abra o VS Code na pasta do projeto
2. Pressione `Ctrl+Shift+P` → **Dev Containers: Reopen in Container**
3. O VS Code irá automaticamente:
   - Fazer o build da imagem (se necessário)
   - Subir o container
   - Instalar todas as extensões listadas no `devcontainer.json`
   - Abrir o terminal já dentro do container

> Para reconstruir após mudanças no `Dockerfile`: `Ctrl+Shift+P` → **Dev Containers: Rebuild Container**

---

## Variáveis de ambiente

| Variável | Padrão | Descrição |
|---|---|---|
| `NB_USER` | `hexdata` | Nome do usuário dentro do container |
| `NB_UID` | `1000` | UID do usuário |
| `NB_GID` | `100` | GID do grupo |
| `JUPYTER_PORT` | `8888` | Porta local para acessar o Jupyter |
| `WORK_DIR` | _(obrigatório)_ | Caminho absoluto da pasta de trabalho no host |

---

## Stack de ferramentas incluídas

### Runtime & Big Data

| Ferramenta | Descrição |
|---|---|
| Apache Spark | Engine de processamento distribuído |
| PySpark | API Python para Spark |
| Delta Lake (`delta-spark`) | Tabelas ACID sobre Parquet, versionamento de dados |
| PyArrow | Columnar in-memory, leitura de Parquet/ORC |
| FastParquet | Alternativa leve para leitura/escrita de Parquet |

### DataFrames & Processamento

| Ferramenta | Descrição |
|---|---|
| Pandas | DataFrame principal para dados tabulares |
| Polars | DataFrame de alta performance (Rust-based) |
| NumPy | Computação numérica vetorizada |
| SciPy | Algoritmos científicos e estatísticos |

### Machine Learning

| Ferramenta | Descrição |
|---|---|
| Scikit-learn | Algoritmos clássicos de ML |

### Visualização

| Ferramenta | Descrição |
|---|---|
| Matplotlib | Gráficos estáticos |
| Seaborn | Visualizações estatísticas sobre matplotlib |
| Plotly | Gráficos interativos em notebooks |

### Banco de Dados & SQL

| Ferramenta | Descrição |
|---|---|
| SQLAlchemy | ORM e abstração de conexão com bancos |

### Qualidade & Validação

| Ferramenta | Descrição |
|---|---|
| Great Expectations | Testes e validação de qualidade de dados |
| Pydantic | Validação e tipagem de dados em Python |

### Formatos de Arquivo

| Ferramenta | Descrição |
|---|---|
| OpenPyXL | Leitura e escrita de arquivos `.xlsx` |
| xlrd | Leitura de arquivos `.xls` legados |

### Extensões VS Code

| Extensão | Descrição |
|---|---|
| Python + Pylance | IntelliSense e type checking |
| Black Formatter | Formatação automática de código |
| Ruff | Linter moderno e rápido (substitui flake8+isort) |
| Jupyter + Renderers | Suporte completo a notebooks |
| Data Wrangler | Exploração visual de DataFrames no VS Code |
| Rainbow CSV | Visualização colorida de arquivos CSV |
| SQLTools | Cliente SQL integrado no editor |
| SQLite Viewer | Abre arquivos `.db` e `.sqlite` |
| Database Client | Interface visual para múltiplos bancos |
| GitLens | Histórico de git linha a linha |
| Git Graph | Visualização gráfica do histórico de commits |
| Docker | Gerenciar containers sem sair do VS Code |
| Parquet Explorer | Abre arquivos `.parquet` diretamente no editor |
| DotENV | Syntax highlight para arquivos `.env` |
| Error Lens | Exibe erros e warnings inline na linha do código |
| autoDocstring | Gera docstrings automaticamente em funções Python |
| Jupyter Cell Tags | Organiza células de notebooks com tags |

---

## Estrutura do projeto

```
DataEngineering/
├── Dockerfile              # Definição da imagem
├── docker-compose.yaml     # Orquestração do container
├── devcontainer.json       # Configuração do VS Code Dev Container
├── .env                    # Variáveis locais (não versionado)
├── .env.example            # Template de variáveis (versionado)
├── .gitignore
└── README.md
```

---

## Comandos úteis

```bash
# Listar imagens Docker locais
docker images

# Ver containers em execução
docker ps

# Ver todos os containers (incluindo parados)
docker ps -a

# Remover imagem da build anterior (para rebuild limpo)
docker rmi pyspark-data-engineering:latest

# Ver uso de disco pelo Docker
docker system df

# Limpar tudo que não está em uso (imagens, containers, redes, cache)
docker system prune -a
```

---

## Troubleshooting

### Porta 8888 já em uso

Altere no `.env`:
```env
JUPYTER_PORT=8889
```
E acesse em `http://localhost:8889`.

### Erro de permissão na pasta de trabalho

Certifique-se de que `NB_UID` no `.env` corresponde ao UID do seu usuário no WSL:
```bash
# Verificar seu UID no WSL
id -u
```

### Container sobe mas Jupyter não abre

Verifique se o Docker Desktop tem acesso ao WSL 2 habilitado em **Settings → Resources → WSL Integration**.

### Reconstruir após mudança no Dockerfile

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```
