# Sistema de Gerenciamento de Biblioteca - Schema do Banco de Dados (MySQL)

Este repositório contém o script SQL para criar a estrutura do banco de dados `BibliotecaDB`, projetado para um sistema de gerenciamento de biblioteca. O script utiliza a sintaxe do MySQL e inclui a definição de tabelas, relacionamentos (chaves estrangeiras), restrições, triggers para logging e uma stored procedure para inserção de dados.

## Visão Geral

O banco de dados `BibliotecaDB` foi modelado para armazenar informações sobre:

*   Livros, seus autores, editoras e categorias.
*   Exemplares físicos dos livros disponíveis.
*   Usuários do sistema (alunos e professores).
*   Empréstimos e devoluções de livros.
*   Reservas de livros.
*   Logs de operações importantes no sistema.

## Tecnologias Utilizadas

*   **Banco de Dados:** MySQL
*   **Engine:** InnoDB (para suporte a transações e chaves estrangeiras)
*   **Character Set:** `utf8mb4` (para suporte completo a Unicode, incluindo emojis)
*   **Collation:** `utf8mb4_unicode_ci` (ordenação e comparação Unicode, case-insensitive)

## Estrutura do Banco de Dados

### Criação do Banco de Dados

```sql
CREATE DATABASE IF NOT EXISTS BibliotecaDB
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE BibliotecaDB;
