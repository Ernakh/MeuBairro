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
select count(votos.fk_alternativa) as 'Quantidade', alternativas.opcao as 'Opção', 
				votacao.tipo as 'Votação', votacao.id as 'ID da Votação'
from votacao
	inner join alternativas
		on alternativas.fk_votacao = votacao.id
	inner join votos
		on votos.fk_alternativa = alternativas.id
	inner join usuario
		on votos.fk_usuario = usuario.id
 group by alternativas.opcao, votacao.tipo, votos.fk_alternativa, votacao.id
 having votacao.id = (select top 1 votacao.id from votacao order by 1 desc)

 select * from votacao 
 insert into endereco values('Rua Tuiuti 874', 'Apto 203', 'Centro', 'Santa Maria', 'RS', '97015040') 
insert into usuario values('Leo', null, 'jogador', '25/09/2001', null, 1, 1)
insert into usuario values('Henrique', null, 'padeiro', '12/05/1998', null, 1, 1)
insert into usuario values('Juliana', null, 'arquiteta', '05/12/1995', null, 1, 1)
insert into usuario values('Isadora', null, 'militar', '18/03/1991', null, 1, 1)
insert into usuario values('Kevin', null, 'segurança', '04/08/1984', null, 1, 1)

insert into votacao (tipo, fk_usuario) values ('Destino de recursos', 1)
insert into alternativas values('Pracinha', 3), ('Festa de fim de ano', 3), ('Piscina', 3)
insert into votos values (2,1),(2,2),(1,3),(2,4),(1,5)

insert into votacao (tipo, fk_usuario) values ('Início da festa de fim de ano', 1)
insert into alternativas values('Meio-dia', 4), ('17:00', 4), ('22:00', 4)
insert into votos values (4,1),(4,2),(5,3),(4,4),(6,5)

select * from votacao
select * from usuario
select * from contagemVotos
