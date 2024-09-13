-- Eli Makoto Higashi Matias
-- RGM: 11221101848

create database teatro_;
use teatro_;

create table pecas_teatro(
id_peca int auto_increment primary key not null,
nome_peca varchar (31),
descricao varchar (70),
duracao TIME
);

delimiter //
create function calcular_media_duracao(id_peca int)
returns decimal(5, 2)
begin
    declare media_duracao decimal(5, 2);
    select avg(time_to_sec(duracao) / 60) into media_duracao
    from pecas_teatro
    where id_peca = id_peca;
    return media_duracao;
end //
delimiter ;

create table apresentacao(
    id_apresentacao int auto_increment primary key not null,
    data_hora datetime,
	id_peca int,
    foreign key (id_peca) references pecas_teatro(id_peca)
);

delimiter //
create function verificar_disponibilidade(data_hora datetime)
returns boolean
begin
    declare disponibilidade boolean;
    select case
        when count(*) > 0 then true
        else false
    end into disponibilidade
    from apresentacao
    where data_hora = data_hora;
    return disponibilidade;
end //
delimiter ;

delimiter //
create procedure agendar_peca(
    in nome_peca varchar(40),
    in descricao varchar(100),
    in duracao time,
    in data_hora datetime
)
begin
    declare id_nova_peca int;
    declare media_duracao decimal(5, 2);
    declare disponibilidade boolean;
    set disponibilidade = verificar_disponibilidade(data_hora);
    if not disponibilidade then
        insert into pecas_teatro (nome_peca, descricao, duracao)
        values (nome_peca, descricao, duracao);
		set id_nova_peca = last_insert_id();
		set media_duracao = calcular_media_duracao(id_nova_peca);
		insert into apresentacao (id_peca, data_hora)
        values (id_nova_peca, data_hora);
    end if;
end //
delimiter ;

insert into pecas_teatro(nome_peca, descricao, duracao) values
('Electra', 'uma tragédia sobre vingança e justiça', '02:10:00'),
('As Nuvens', 'um homem individualizado, que busca aprender argumentos falaciosos na escola de Sócrates para enganar seus credores', '03:15:00'),
('Hamlet', 'uma tragédia que narra a história do príncipe Hamlet, que busca vingança pelo assassinato de seu pai', '02:15:00');

insert into apresentacao(data_hora, id_peca) values
('2025-10-07 22:00:00', 1),
('2025-10-10 14:10:00', 2),
('2025-12-21 20:10:00', 3);

call agendar_peca('Electra', 'uma tragédia sobre vingança e justiça', '02:10:00', '2025-10-07 22:00:00');

select * from apresentacao;
select * from pecas_teatro;