SELECT
    FHBNNF  AS "Número da Nota Fiscal",
    FHBSER  AS "Série da Nota Fiscal",
    FHMCU   AS "Centro de Custo / Filial",
    FHCO    AS "Empresa",
    FHFCO   AS "Empresa Fiscal",
    FHSHAN  AS "Address Number do Destinatário",
    FHAN8   AS "Address Number do Emitente",
    FHBCGT  AS "CNPJ/CPF",
    FHSHST  AS "Estado do Destinatário",
    FHBCGF  AS "Inscrição Estadual",

    -- Data de Emissão
    CONVERT(VARCHAR(10),
        DATEADD(DAY, CAST(RIGHT(CAST(FHISSU AS VARCHAR),3) AS INT) - 1,
            DATEFROMPARTS(
                CASE 
                    WHEN LEFT(CAST(FHISSU AS VARCHAR),1) = '1' THEN 2000 
                    ELSE 1900 
                END 
                + CAST(SUBSTRING(CAST(FHISSU AS VARCHAR),2,2) AS INT),
                1, 1
            )
        ), 103
    ) AS "Data de Emissão da NF",

    FHFRTH  AS "Frete",
    FHLICP  AS "Chave de Acesso / DANFE",
    FHSTCD  AS "Status Code",

    -- Usuário (ID)
    FHUSER  AS "User ID",

    FHPID   AS "Program ID",

    -- Data Última Atualização
    CONVERT(VARCHAR(10),
        DATEADD(DAY,
            CAST(RIGHT(CAST(FHUPMJ AS VARCHAR),3) AS INT) - 1,
            DATEFROMPARTS(
                CASE 
                    WHEN LEFT(CAST(FHUPMJ AS VARCHAR),1) = '1' THEN 2000 
                    ELSE 1900 
                END 
                + CAST(SUBSTRING(CAST(FHUPMJ AS VARCHAR),2,2) AS INT),
                1, 1
            )
        ), 103
    ) AS "Data Última Atualização",

    -- Hora Última Atualização
    CONVERT(VARCHAR(8),
        DATEADD(SECOND, CAST(FHTDAY AS INT), '00:00:00'),
        108
    ) AS "Hora Última Atualização",

    FHUSB1  AS "Campo Customizado"

FROM
    PRODDTA.F7601B

WHERE
    FHUPMJ BETWEEN 125001 AND 126116;
