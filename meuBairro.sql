create database meuBairro

create table configuracoes
(
	id integer primary key identity,
	cpf varchar(14),
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
	foreign key (fk_usuario) references usuario(id),
	inicio datetime2 generated always as row start not null,
	fim datetime2 generated always as row end not null,
		period for system_time (inicio, fim)
)
with (system_versioning = ON (history_table = dbo.servicosHistorico))


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
	foreign key (fk_usuario) references usuario(id),
	inicio datetime2 generated always as row start not null,
	fim datetime2 generated always as row end not null,
		period for system_time (inicio, fim)
)
with (system_versioning = ON (history_table = dbo.votacaoHistorico))

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
	foreign key (fk_usuario) references usuario(id),
	inicio datetime2 generated always as row start not null,
	fim datetime2 generated always as row end not null,
		period for system_time (inicio, fim)
)
with (system_versioning = ON (history_table = dbo.denunciasHistorico))

create table dependentes
(
	id integer primary key identity,
	tipo varchar(20),
	fk_usuario integer,
	foreign key (fk_usuario) references usuario(id)
);
go

create trigger validaDadosConfiguracoes
on configuracoes
instead of insert
as

	declare @cpf varchar(14)
	declare @rg varchar(20)
	declare @email varchar(30)
	declare @senha varchar(30)

	select @cpf = (select inserted.cpf from inserted)
	select @rg = (select inserted.rg from inserted)
	select @email = (select inserted.email from inserted)
	select @senha = (select inserted.senha from inserted)
	
	IF @email LIKE '%_@__%.__%' and @cpf LIKE '%_._%._%-_%'
	begin
		
		print('dados válidos!')
		insert into configuracoes(cpf, rg, email, senha) values (@cpf, @rg, @email, @senha)

	end
	ELSE
	begin

		rollback transaction

	end


insert into configuracoes(cpf, rg, email, senha) values ('111.222.333-44', '12312', 'fulano@gmail.com', '12345')
--insert into configuracoes(cpf, rg, email, senha) values ('11111111122', '12312', 'fulanogmailcom', '12345') -- deve acusar erro

select * from configuracoes

drop trigger validaDadosConfiguracoes

drop table configuracoes

create view contagemVotos as
select count(usuario.id) as 'quantidade', alternativas.opcao, votacao.tipo, votos.fk_alternativa, votos.fk_usuario
from votacao
inner join alternativas
on alternativas.fk_votacao = votacao.id
inner join votos
 on votos.fk_alternativa = alternativas.id
 inner join usuario
 on votos.fk_usuario = usuario.id
 group by alternativas.opcao, votacao.tipo, votos.fk_alternativa, votos.fk_usuario
