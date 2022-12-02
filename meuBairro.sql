create database meuBairro

create table configuracoes
(
	id integer primary key identity,
	cpf varchar(11),
	rg varchar(20),
	email varchar(40),
	senha varchar(30)
)

create table endereco
(
	id integer primary key identity,
	logradouro varchar(50),
	complemento varchar(40),
	bairro varchar(30),
	localidade varchar(30),
	uf varchar(2),
	cep varchar(8)
)

create table espacoFisico
(
	id integer primary key identity,
	nome varchar(40),
	capacidade integer,
	fk_endereco integer,
	foreign key (fk_endereco) references endereco(id)
)

create table eventos
(
	id integer primary key identity,
	data datetime,
	descricao varchar(60),
	tipo varchar(30),
	status varchar(20),
	fk_espacoFisico integer,
	foreign key (fk_espacoFisico) references espacoFisico(id)
)

create table usuario
(
	id integer primary key identity,
	nome varchar(40),
	nomeSocial varchar(40),
	profissao varchar(25),
	dataNasc date,
	conjuge integer,
	fk_configuracoes integer,
	fk_endereco integer,
	foreign key (conjuge) references usuario(id),
	foreign key (fk_configuracoes) references configuracoes(id),
	foreign key (fk_endereco) references endereco(id)
)

create table servicos
(
	id integer primary key identity,
	nome varchar(30),
	descricao varchar(50),
	fk_usuario integer,
	foreign key (fk_usuario) references usuario(id)
)

create table redesSociais
(
	id integer primary key identity,
	nomeRede varchar(40),
	link varchar (60),
	fk_usuario integer,
	foreign key (fk_usuario) references usuario(id)
)

create table contato
(
	id integer primary key identity,
	tipo varchar(25),
	descricao varchar(50),
	fk_usuario integer,
	foreign key (fk_usuario) references usuario(id)
)

create table votacao
(
	id integer primary key identity,
	tipo varchar(50),
	fk_usuario integer,
	foreign key (fk_usuario) references usuario(id)
)

create table alternativas
(
	id integer primary key identity,
	opcao varchar(30),
	fk_votacao integer,
	foreign key (fk_votacao) references votacao(id)
)

create table votos
(
	id integer primary key identity,
	fk_alternativa integer,
	fk_usuario integer,
	foreign key (fk_alternativa) references alternativas(id),
	foreign key (fk_usuario) references usuario(id)
)

create table denunciaCategoria
(
	id integer primary key identity,
	nome varchar(30)
)

create table denuncia
(
	id integer primary key identity,
	titulo varchar(40),
	descricao varchar(100),
	data datetime,
	status varchar(30),
	fk_categoria integer,
	fk_usuario integer,
	foreign key (fk_categoria) references denunciaCategoria(id),
	foreign key (fk_usuario) references usuario(id)
)

create table dependentes
(
	id integer primary key identity,
	tipo varchar(20),
	fk_usuario integer,
	foreign key (fk_usuario) references usuario(id)
)
