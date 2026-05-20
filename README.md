# PySpark Data Engineering — Dev Container

Ambiente de desenvolvimento completo para Engenharia e Ciência de Dados, baseado em **Apache Spark**, **Python 3.11** e **Jupyter Notebook**, executado em container Docker com integração ao VS Code Dev Containers.

---

## Sumário

- [Pré-requisitos](#pré-requisitos)
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

## Configuração inicial

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd devcontainer
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
devcontainer/
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
