@AbapCatalog.sqlViewName: 'zget_up_cds'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'zget_up_v'
@Metadata.ignorePropagatedAnnotations: true
define view zget_up_v 
//with parameters p_req_no: znoreq, p_werks: werks_d, p_lgort: lgort_d
as select from zgdmmt0001 as z
left outer join t001w as tw on z.werks = tw.werks
left outer join t001l as tl on z.lgort = tl.lgort  and z.werks = tl.werks
left outer join makt as m1 on z.matnr = m1.matnr
left outer join mara as m2 on z.matnr = m2.matnr
left outer join zgdmmt0002 as z2 on z2.zrecd = z.zrecd
left outer join lfa1 as l on z.lifnr = l.lifnr
left outer join mch1 as m3 on z.matnr = m3.matnr and z.charg = m3.charg
{
    z.werks as werks,
    tw.name1 as plant_description,
    z.lgort as lgort,
    lgobe as lgobe,
    mblnr as mblnr,
    mjahr as mjahr,
    req_no as req_no,
    cast(concat(concat(concat(concat( substring(req_date, 7, 2),'.'),substring(req_date, 5, 2)),'.'),left(req_date, 4)) as abap.char(10) ) as req_date,
    cast(concat(concat(concat(concat( left(req_time, 2),':'),substring(req_time, 3, 2)),':'),substring(req_time, 5, 2)) as abap.char(8) ) as req_time,
    requester as requester,
    zfrmtl as zfrmtl,
    bbk_no as bbk_no,
    cast(concat(concat(concat(concat( substring(bbk_date, 7, 2),'.'),substring(bbk_date, 5, 2)),'.'),left(bbk_date, 4)) as abap.char(10) ) as bbk_date,
    cast(concat(concat(concat(concat( left(bbk_time, 2),':'),substring(bbk_time, 3, 2)),':'),substring(bbk_time, 5, 2)) as abap.char(8) ) as bbk_time,
    scrap_no as scrap_no,
    scrap_year as scrap_year,
    bap_no as bap_no,
    cast(concat(concat(concat(concat( substring(bap_date, 7, 2),'.'),substring(bap_date, 5, 2)),'.'),left(bap_date, 4)) as abap.char(10) ) as bap_date,
    cast(concat(concat(concat(concat( left(bap_time, 2),':'),substring(bap_time, 3, 2)),':'),substring(bap_time, 5, 2)) as abap.char(8) ) as bap_time,
    cla_no as cla_no,
    cast(concat(concat(concat(concat( substring(cla_date, 7, 2),'.'),substring(cla_date, 5, 2)),'.'),left(cla_date, 4)) as abap.char(10) ) as cla_date,
    cast(concat(concat(concat(concat( left(cla_time, 2),':'),substring(cla_time, 3, 2)),':'),substring(cla_time, 5, 2)) as abap.char(8) ) as cla_time,
    cla_sts as cla_sts,
    
    z.matnr as matnr,
    maktx as maktx,
    matkl as matkl,
    z.charg as charg,
//    @Semantics.quantity.unitOfMeasure: 'meins'
//    cast(menge as abap.quan(13,0)) as menge,
    menge as menge,
    z.meins as meins,
    value_blocked as value_blocked,
    z.zrecd as zrecd,
    z2.zrecdt as zrecdt,
    z.lifnr as lifnr,
    l.name1 as name1,
    cast(left(m3.hsdat, 4) as abap.char(4)) as hsdat,
    case when m3.vfdat = '00000000' then 'NON EXPIRED' else case when m3.vfdat < z.req_date then 'EXPIRED' else 'NON EXPIRED' end end as status_exp,
    case when mtart = 'ZCGB' or mtart = 'ZPHA' then 'X' else ' ' end as fg 
}
//where ( req_no = $parameters.p_req_no  or req_no = ' ' )
//and ( z.werks = $parameters.p_werks or z.werks = ' ' )
//and ( z.lgort = $parameters.p_lgort or z.lgort = ' ' )
