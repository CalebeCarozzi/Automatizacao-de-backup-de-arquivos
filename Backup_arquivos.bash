#!/bin/bash 

# ADMINISTRAÇÃO DE SISTEMAS - BACKUP DE ARQUIVOS
# CALEBE RODRIGUES CAROZZI 

# FUNÇÃO PARA VERIFICAR SE UM DIRETÓRIO EXISTE ----------
verificar_diretorio() {
    local nome_variavel="$1"            # Primeiro argumento: nome da variável onde será salvo o caminho válido
    local mensagem="$2"                 # Segundo argumento: mensagem a ser exibida ao usuário
    local diretorio                     # Variável local para armazenar temporariamente a entrada do usuário

    echo -n "$mensagem"                 # Exibe a mensagem
    read -r diretorio                   # Lê o diretório informado pelo usuário

    if [ ! -d "$diretorio" ]; then      # Se o diretório não existir ou o caminho estiver errado, avisa e chama a função novamente
        echo "O diretório '$diretorio' é inexistente ou inválido."
        verificar_diretorio "$nome_variavel" "$mensagem"  # Recursão- tenta novamente com os mesmo argumentos que já tinhamos colcoado
        return
    fi

    eval "$nome_variavel=\"\$diretorio\""  # Usa eval para salvar o caminho válido na variável com o nome fornecido
}

# VARIÁVEIS GLOBAIS ----------
a=0                                 # Índice do array de origens
declare -a origens                  # Declaração do array de diretórios de origem

# FUNÇÃO PARA ADICIONAR VÁRIOS DIRETÓRIOS DE ORIGEM ----------
adicionar_origens() {
    verificar_diretorio "nova_origem" "Digite o caminho do diretório de origem: "  # Solicita um diretório válido com o uso da função de verificação
    origens[a]="$nova_origem"      # Adiciona o diretório ao array de origens
    a=$((a + 1))                    # Incrementa o índice do array

    echo -n "Deseja adicionar mais um diretório de origem? [s/N]: "  # Pergunta se deseja adicionar outro diretorio de origem
    read -r resposta
    resposta=$(echo "$resposta" | tr '[:upper:]' '[:lower:]')        # Converte a resposta para minúscula

    if [[ "$resposta" == "s" ]]; then       # Verifica e se resposta = s
        adicionar_origens          # Recursão: chama a função novamente
    fi
}

# FUNÇÃO PARA EXECUTAR O BACKUP ----------
backup() {
    local destino_funcao="$1"         # Diretório de destino (passado como argumento)
    local usar_log=""                 # String que conterá o argumento do log (se necessário)
    local logfile=""                  # Caminho completo do arquivo de log

    echo
    echo "Deseja salvar o relatório do backup em um arquivo de log? [s/N]: "  # Pergunta se quer salvar um relatório no arquivo log 
    read -r resposta
    resposta=$(echo "$resposta" | tr '[:upper:]' '[:lower:]')       # Converte a resposta para minúscula

    if [[ "$resposta" == "s" ]]; then                     # se quiser colocar o relatório
        mkdir -p "$destino_funcao/logsync"                # Garante que o diretório de log exista
        logfile="$destino_funcao/logsync/logsync.txt"     # Define o caminho do arquivo de log - que vai ser em um diretório chamado logsync dentro do destino
        usar_log="--log-file=$logfile"                    # Prepara a flag para ser usada no comando rsync
        echo "Log salvo em: $logfile"                     # Apenas mostra aonde log vai ser salvo 
    fi

    echo
    echo "Deseja simular o backup antes da execução real? [s/N]: " # Pergunta se quer executar a simulação do backup 
    read -r resposta
    resposta=$(echo "$resposta" | tr '[:upper:]' '[:lower:]')       # Converte a resposta para minúscula

    if [[ "$resposta" == "s" ]]; then
        echo
        echo "Executando simulação..."
        rsync -auvn $usar_log "${origens[@]/%//}" "$destino_funcao"/  # Simulação do rsync (-n)
        echo "Fim da simulação."
    fi

    echo
    echo "Confirme a execução do comando abaixo para iniciar o backup real:"
    echo "rsync -auv $usar_log ${origens[*]/%//} $destino_funcao/"    # Mostra o comando que será executado para confimação do usuário
    echo
    echo "[s] - Confirmar"
    echo "[n] - Cancelar"
    echo -n "Resposta: "
    read -r resposta
    resposta=$(echo "$resposta" | tr '[:upper:]' '[:lower:]')       # Converte a resposta para minúscula
    echo

    if [[ "$resposta" == "s" ]]; then           # Se confirmar, o backup vai ser executado
        echo "Backup iniciado..."
        rsync -auv $usar_log "${origens[@]/%//}" "$destino_funcao"/   # Executa o backup de fato, usando o "${origens[@]/%//}" para exibir todos os dir de 
        echo "Backup finalizado!"                                     # origem que foram colocados, com um espaço no meio e uma barra depois de cada caminho
    else                                        #se não confimar, cancela o processo
        echo "Backup cancelado."
    fi
}

# FUNÇÃO PRINCIPAL DO MENU ------------
menu_inicial() {

    adicionar_origens                                  # Chama a função para adicionar diretórios de origem
    verificar_diretorio "destino" "Digite o caminho do diretório de destino: "  # Solicita o diretório de destino com os respectivos argumentos

    echo
    echo "Arquivos do backup configurado!"
    echo
    echo "Diretório(s) de origem: ${origens[*]}"        # Exibe os diretórios de origem que foram escolhidos
    echo "Diretório de destino: $destino"               # Exibe o diretório de destino que foram escolhidos
    echo

    echo "Deseja iniciar o backup ou reconfigurar os arquivos?"    # Após escolher os diretórios de origem e destino, e mostrar os digitados
    echo "  [i] Iniciar o backup com os arquivos atuais"           # Pergunta se quer escolher os diretórios novamente caso houve algum erro
    echo "  [r] Reconfigurar diretórios de origem e destino"       # Ou se pode continuar o processo
    echo -n "Escolha: "
    read -r resposta
    resposta=$(echo "$resposta" | tr '[:upper:]' '[:lower:]')

    if [[ "$resposta" == "r" ]]; then       # Se escolher reconfigurar:
        a=0            # Reinicia o contador do array        
        origens=()     # Limpa o array de origens
        destino=""     # Limpa o destino
        menu_inicial   # Reinicia o processo
    fi

    backup "$destino"  # Executa a função do backup com os diretórios escolhidos

    echo
    echo -n "Deseja realizar outro backup? [s/N]: "    # Pergunta ao usuário se deseja executar outro backup
    read -r resposta
    resposta=$(echo "$resposta" | tr '[:upper:]' '[:lower:]')

    if [[ "$resposta" == "s" ]]; then           # Se quiser realizar outro: 
        echo
        echo "Reiniciando processo de backup..."        # Apaga tudo para reiniciar
        a=0              # Reinicia o contador do array
        origens=()       # Limpa o array
        destino=""       # Limpa o destino
        menu_inicial     # Reinicia o processo
    else                                    # Se não quiser, encerra o processo
        echo
        echo "Encerrando o programa."  # Mensagem final
        exit 0  # Ajuda a encerrar o programa sem erros
    fi
}

echo "=========================================="
echo "      SCRIPT DE BACKUP DE ARQUIVOS        "
echo "        Desenvolvido por Calebe           "
echo "=========================================="
echo
menu_inicial  # Chamada inicial do programa, ponto de entrada principal
