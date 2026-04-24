SELECT
    DECODE(
        nf.ds_processo,
        'MAXIMO', NVL(item.cd_produto_maximo, item.fcat_cd_produto),
        item.grco_cd_produto
    )                                       AS "CD PRODUTO",
    NVL(item.ds_produto, prod.ds_produto_port) AS "DS PRODUTO",
    item.cd_trib_icms                       AS "CST",
    item.tp_operacao_fiscal                 AS "P/S",
    nf.dt_emissao                           AS "DT EMISSAO",
    nf.nr_nf                                AS "NR NOTA",
    serie.cd_referencia                     AS "SERIE",
    DECODE(nf.tp_nf, 'E', 'ENTRADA', 'S', 'SAIDA') AS "TP NF",
    DECODE(nf.tp_inclusao, 'D','DIGITADA', 'G','GERADA', nf.tp_inclusao) AS "TP INCLUSAO",
    DECODE(nf.st_ativa, 'S','SIM', 'N','NAO')      AS "ATIVA",
    DECODE(nf.st_nf, 'E','EMITIDA', 'P','PRE-NOTA', 'C','CANCELADA') AS "SITUACAO",
    cfop.cd_referencia                      AS "CFOP",
    cfop.ds_referencia                      AS "DS CFOP",
    nf.clif_cd_clifor                       AS "CLIFOR",
    titu.nm_razaosocial                     AS "RAZAO SOCIAL",
    DECODE(
        titu.tp_pessoa,
        2,
            TRIM(TO_CHAR(titu.nr_cgc, '00G000G000')) || '/' ||
            TRIM(TO_CHAR(titu.nr_cgcordem, '0000')) || '-' ||
            TRIM(TO_CHAR(titu.nr_cgcdv, '00')),
        1,
            TRIM(TO_CHAR(titu.nr_cgc, '000G000G000')) || '-' ||
            TRIM(TO_CHAR(titu.nr_cgcdv, '00')),
        TRIM(TO_CHAR(titu.nr_cgc, '0000000000')) ||
        TRIM(TO_CHAR(titu.nr_cgcordem, '0000'))  ||
        TRIM(TO_CHAR(titu.nr_cgcdv, '00'))
    )                                       AS "CNPJ",
    titu.rmat_cd_ramoativ                   AS "RAMO ATIVIDADE",
    item.movi_cd_movimentacao               AS "CD MOVTO",
    mov.ds_movimentacao                     AS "DS MOVTO",
    item.tp_origem_mercadoria               AS "ORG MERCADORIA",
    SUBSTR(org.rv_meaning, 1, 1)            AS "COD MERCADORIA",
    SUBSTR(org.rv_meaning, 3, 30)           AS "TP ORG",
    nf.dvsa_cd_divisao                      AS "DIVISAO",
    div.ds_divisao                          AS "DS DIVISAO",
    NVL(DECODE(item.nr_conta_contabil, 0, NULL, item.nr_conta_contabil), '') ||
    NVL(DECODE(item.nr_conta_detalhe, 0, NULL, item.nr_conta_detalhe), '') AS "CONTA CONTABIL",
    NVL(item.qt_item, 0)                    AS "QUANTIDADE",
    NVL(item.vl_total_liquido, 0)           AS "VL CONTABIL",
    NVL(item.vl_total_liquido, 0)           AS "VL LIQUIDO",
    NVL(item.vl_total_bruto, 0)             AS "VL BRUTO",
    NVL(icms.vl_base_calculo, 0)            AS "BS CALCULO",
    NVL(icms.pc_imposto, 0)                 AS "ALIQUOTA",
    NVL(icms.vl_imposto, 0)                 AS "VL ICMS",
    NVL(icms.vl_subst_trib, 0)              AS "VL ICMS ST",
    NVL(icms.vl_outras, 0)                  AS "VL ICMS OUTRAS",
    NVL(icms.vl_isento, 0)                  AS "VL ICMS ISENTO",
    NVL(ipi.vl_imposto, 0)                  AS "VL IPI",
    NVL(item.vl_total_liquido, 0)
      - NVL(icms.vl_base_calculo, 0)
      - NVL(icms.vl_outras, 0)
      - NVL(icms.vl_isento, 0)             AS "VL DIFERECA",
    icms.cd_trib_icms_ipi                   AS "ST TRB",
    sttb.ds_classif_tributaria              AS "DS ST TRB",
    est.sg_estado                           AS "UF",
    nf.loca_cd_local_fisico                 AS "LOC FISICO",
    nf.loca_cd_local_fiscal                 AS "LOC FISCAL",
    nf.comp_cd_companhia                    AS "COMPANHIA",
    nf.nr_lancamento                        AS "LANCTO",
    item.nr_sequencia                       AS "SQ",
    nf.dt_emissao_fornec                    AS "DT DOCTO",
    nf.dt_criacao                           AS "DT CRIACAO",
    NVL(sped.cd_referencia, docto.cd_referencia) AS "DOC ESP",
    NVL(item.nbm_nr_nbm, prod.nbm_nr_nbm)   AS "NCM",
    cid.ds_cidade                           AS "MUNICIPIO",
    DECODE(nf.ds_processo, 'MAXIMO', nf.ch_para_zim) AS "FATURA MAXIMO",
    NVL(icmsdf.vl_imposto, 0)               AS "VL ICMSDF",
    NVL(icmsaf.vl_imposto, 0)               AS "VL ICMSAF",
    NVL(icdfaf.vl_imposto, 0)               AS "VL ICDFAF",
    pisconfis.cd_trib_icms_ipi              AS "CST PIS CONFINS",
    NVL(pisconfis.vl_imposto, 0)            AS "VL PIS 647",
    NVL(pis5979.vl_imposto, 0)              AS "VL PIS 5979",
    NVL(pis6912.vl_imposto, 0)              AS "VL PISFAT 6912",
    NVL(confins648.vl_imposto, 0)           AS "VL COFINS 648",
    NVL(confis5960.vl_imposto, 0)           AS "VL COFINS 5960",
    NVL(confis5856.vl_imposto, 0)           AS "VL COFINSFAT 5856",
    NVL(NVL(nfel.cd_chave, fret.cd_chave), nfe.cd_chave_nfe) AS "CHAVE ELETRONICA",
    nfel.cd_status_retorno                  AS "ID RETORNO",
    nfel.cd_status_ret_canc                 AS "ID CANCELAMENTO",
    item.mvla_lcen_cd_localidade || '-' || item.mvla_lcen_cd_localidade_entreg AS "LOCAL ENTREGA",
    -- ctrs.nr_contrato                        AS "CONTRATO",  -- REMOVIDO: faltam joins seguros
    nf.ds_processo                          AS "PROCESSO",
    nf.ds_obsnf                             AS "OBSERVACAO"
FROM
    emif_nfi_nota_fiscal       nf,
    emif_inf_itens_nf          item,
    corp_produto               prod,
    cg_ref_codes               org,
    corp_divisao               div,
    corp_titular               titu,
    corp_movimentacao          mov,
    corp_tabela_referencia     docto,
    corp_tabela_referencia     sped,
    corp_tabela_referencia     cfop,
    corp_tabela_referencia     serie,
    corp_estado                est,
    corp_endereco              end,
    corp_cidade                cid,
    nfel_nota                  nfel,
    emif_nfi_complemento_nf    nfe,
    nfel_frete                 fret,
    -- emif_inf_adicional         adia,      -- REMOVIDO: faltam joins
    -- ctrs_contrato              ctrs,      -- REMOVIDO: faltam joins
    emif_imposto_item_nf       icms,
    fisc_classificacao_tributaria sttb,
    emif_imposto_item_nf       ipi,
    emif_imposto_item_nf       icmsdf,
    emif_imposto_item_nf       icmsaf,
    emif_imposto_item_nf       icdfaf,
    emif_imposto_item_nf       pisconfis,
    emif_imposto_item_nf       pis5979,
    emif_imposto_item_nf       pis6912,
    emif_imposto_item_nf       confins648,
    emif_imposto_item_nf       confis5960,
    emif_imposto_item_nf       confis5856
WHERE
    -- Joins principais
    nf.loca_cd_local_fisico   = item.ennf_cd_local_fisico
AND nf.loca_cd_local_fiscal   = item.ennf_cd_local_fiscal
AND nf.comp_cd_companhia      = item.ennf_cd_companhia
AND nf.nr_lancamento          = item.ennf_nr_lancamento
    -- PERÍODO: 01/07/2025 até o final do dia de hoje
AND nf.dt_emissao >= DATE '2025-01-01'
AND nf.dt_emissao <=  DATE '2026-04-02'
    -- Empresa e tipo de nota (somente SAÍDA)
AND nf.comp_cd_companhia IN ('OL1','0U6')
AND nf.tp_nf = 'S'
    -- Demais relacionamentos
AND prod.cd_produto             = item.grco_cd_produto
AND div.cd_divisao              = nf.dvsa_cd_divisao
AND titu.cd_clifor              = nf.clif_cd_clifor
AND mov.cd_movimentacao         = item.movi_cd_movimentacao
AND docto.nr_sequencia          = nf.tbre_nr_sequencia_tpdoc
AND cfop.nr_sequencia           = item.tbre_nr_sequencia_cfop
AND serie.nr_sequencia          = nf.tbre_nr_sequencia_serie
AND SUBSTR(org.rv_low_value, 1, 1) = item.tp_origem_mercadoria
AND org.rv_domain               = 'DM_ORIGEM'
AND end.clif_cd_clifor          = nf.clif_cd_clifor
AND end.cd_endereco             = nf.ende_cd_endereco_entr
AND cid.esta_cd_estado          = end.sbar_cd_estado
AND cid.cd_cidade               = end.sbar_cd_cidade
AND est.cd_estado               = end.sbar_cd_estado
    -- Outer joins
AND sped.nr_sequencia      (+) = nfe.tbre_nr_sequencia_tpdoc_nfel
AND nfel.cd_localidade_fisico (+) = nf.loca_cd_local_fisico
AND nfel.cd_localidade_fiscal (+) = nf.loca_cd_local_fiscal
AND nfel.cd_companhia      (+) = nf.comp_cd_companhia
AND nfel.nr_lancamento     (+) = nf.nr_lancamento
AND nfe.ennf_cd_local_fisico   (+) = nf.loca_cd_local_fisico
AND nfe.ennf_cd_local_fiscal   (+) = nf.loca_cd_local_fiscal
AND nfe.ennf_cd_companhia      (+) = nf.comp_cd_companhia
AND nfe.ennf_nr_lancamento     (+) = nf.nr_lancamento
AND fret.cd_local_fisico   (+) = nf.fret_cd_localidade_fisica
AND fret.cd_local_fiscal   (+) = nf.fret_cd_localidade_fiscal
AND fret.cd_companhia      (+) = nf.fret_cd_companhia
AND fret.nr_lancamento     (+) = nf.fret_nr_lancamento
AND icms.eiin_cd_local_fisico  (+) = item.ennf_cd_local_fisico
AND icms.eiin_cd_local_fiscal  (+) = item.ennf_cd_local_fiscal
AND icms.eiin_cd_companhia     (+) = item.ennf_cd_companhia
AND icms.eiin_nr_lancamento    (+) = item.ennf_nr_lancamento
AND icms.eiin_nr_sequencia     (+) = item.nr_sequencia
AND icms.cd_imposto            (+) = '347'
AND icms.st_situacao           (+) = 'A'
-- Evitar função no lado indexado: comparar texto com texto
AND icms.cd_trib_icms_ipi      (+) = TO_CHAR(sttb.cd_classif_tributaria)
AND sttb.st_situacao           (+) = 'A'
AND ipi.eiin_cd_local_fisico   (+) = item.ennf_cd_local_fisico
AND ipi.eiin_cd_local_fiscal   (+) = item.ennf_cd_local_fiscal
AND ipi.eiin_cd_companhia      (+) = item.ennf_cd_companhia
AND ipi.eiin_nr_lancamento     (+) = item.ennf_nr_lancamento
AND ipi.eiin_nr_sequencia      (+) = item.nr_sequencia
AND ipi.cd_imposto             (+) = '399'
AND ipi.st_situacao            (+) = 'A'
AND icmsdf.eiin_cd_local_fisico (+) = item.ennf_cd_local_fisico
AND icmsdf.eiin_cd_local_fiscal (+) = item.ennf_cd_local_fiscal
AND icmsdf.eiin_cd_companhia    (+) = item.ennf_cd_companhia
AND icmsdf.eiin_nr_lancamento   (+) = item.ennf_nr_lancamento
AND icmsdf.eiin_nr_sequencia    (+) = item.nr_sequencia
AND icmsdf.cd_imposto           (+) = '5745'
AND icmsdf.st_situacao          (+) = 'A'
AND icmsaf.eiin_cd_local_fisico (+) = item.ennf_cd_local_fisico
AND icmsaf.eiin_cd_local_fiscal (+) = item.ennf_cd_local_fiscal
AND icmsaf.eiin_cd_companhia    (+) = item.ennf_cd_companhia
AND icmsaf.eiin_nr_lancamento   (+) = item.ennf_nr_lancamento
AND icmsaf.eiin_nr_sequencia    (+) = item.nr_sequencia
AND icmsaf.cd_imposto           (+) = '7046'
AND icmsaf.st_situacao          (+) = 'A'
AND icdfaf.eiin_cd_local_fisico (+) = item.ennf_cd_local_fisico
AND icdfaf.eiin_cd_local_fiscal (+) = item.ennf_cd_local_fiscal
AND icdfaf.eiin_cd_companhia    (+) = item.ennf_cd_companhia
AND icdfaf.eiin_nr_lancamento   (+) = item.ennf_nr_lancamento
AND icdfaf.eiin_nr_sequencia    (+) = item.nr_sequencia
AND icdfaf.cd_imposto           (+) = '7226'
AND icdfaf.st_situacao          (+) = 'A'
AND pisconfis.eiin_cd_local_fisico (+) = item.ennf_cd_local_fisico
AND pisconfis.eiin_cd_local_fiscal (+) = item.ennf_cd_local_fiscal
AND pisconfis.eiin_cd_companhia    (+) = item.ennf_cd_companhia
AND pisconfis.eiin_nr_lancamento   (+) = item.ennf_nr_lancamento
AND pisconfis.eiin_nr_sequencia    (+) = item.nr_sequencia
AND pisconfis.cd_imposto           (+) = '647'
AND pisconfis.st_situacao          (+) = 'A'
AND pis5979.eiin_cd_local_fisico   (+) = item.ennf_cd_local_fisico
AND pis5979.eiin_cd_local_fiscal   (+) = item.ennf_cd_local_fiscal
AND pis5979.eiin_cd_companhia      (+) = item.ennf_cd_companhia
AND pis5979.eiin_nr_lancamento     (+) = item.ennf_nr_lancamento
AND pis5979.eiin_nr_sequencia      (+) = item.nr_sequencia
AND pis5979.cd_imposto             (+) = '5979'
AND pis5979.st_situacao            (+) = 'A'
AND pis6912.eiin_cd_local_fisico   (+) = item.ennf_cd_local_fisico
AND pis6912.eiin_cd_local_fiscal   (+) = item.ennf_cd_local_fiscal
AND pis6912.eiin_cd_companhia      (+) = item.ennf_cd_companhia
AND pis6912.eiin_nr_lancamento     (+) = item.ennf_nr_lancamento
AND pis6912.eiin_nr_sequencia      (+) = item.nr_sequencia
AND pis6912.cd_imposto             (+) = '6912'
AND pis6912.st_situacao            (+) = 'A'
AND confins648.eiin_cd_local_fisico (+) = item.ennf_cd_local_fisico
AND confins648.eiin_cd_local_fiscal (+) = item.ennf_cd_local_fiscal
AND confins648.eiin_cd_companhia    (+) = item.ennf_cd_companhia
AND confins648.eiin_nr_lancamento   (+) = item.ennf_nr_lancamento
AND confins648.eiin_nr_sequencia    (+) = item.nr_sequencia
AND confins648.cd_imposto           (+) = '648'
AND confins648.st_situacao          (+) = 'A'
AND confis5960.eiin_cd_local_fisico (+) = item.ennf_cd_local_fisico
AND confis5960.eiin_cd_local_fiscal (+) = item.ennf_cd_local_fiscal
AND confis5960.eiin_cd_companhia    (+) = item.ennf_cd_companhia
AND confis5960.eiin_nr_lancamento   (+) = item.ennf_nr_lancamento
AND confis5960.eiin_nr_sequencia    (+) = item.nr_sequencia
AND confis5960.cd_imposto           (+) = '5960'
AND confis5960.st_situacao          (+) = 'A'
AND confis5856.eiin_cd_local_fisico (+) = item.ennf_cd_local_fisico
AND confis5856.eiin_cd_local_fiscal (+) = item.ennf_cd_local_fiscal
AND confis5856.eiin_cd_companhia    (+) = item.ennf_cd_companhia
AND confis5856.eiin_nr_lancamento   (+) = item.ennf_nr_lancamento
AND confis5856.eiin_nr_sequencia    (+) = item.nr_sequencia
AND confis5856.cd_imposto           (+) = '5856'
AND confis5856.st_situacao          (+) = 'A'
AND icms.cd_trib_icms_ipi IS NOT NULL
