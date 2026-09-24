@AbapCatalog.sqlViewName: 'zkmm_cds'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZKMM_V01'
@Metadata.ignorePropagatedAnnotations: true
define view ZKMM_V01 
with parameters p_werks: werks_d
//                p_uname: usnam
as select from caufv
join resb on resb.wempf = caufv.aufnr
left outer join mseg on resb.rsnum = mseg.rsnum
left outer join afpo on caufv.aufnr = afpo.aufnr
left outer join makt on afpo.matnr = makt.matnr
//left outer join rkpf on resb.rsnum = rkpf.rsnum
left outer join mkpf on mseg.mblnr = mkpf.mblnr and mseg.mjahr = mkpf.mjahr
left outer join t001w on t001w.werks = resb.werks
{
    cast( 0 as abap.int8 ) as nomor, 
    resb.werks,
    t001w.name1,
    caufv.aufnr,
    caufv.gstrp,
    resb.rsnum,
    resb.bdter,
    resb.sgtxt,
    afpo.matnr as product_fg,
    afpo.charg,
    makt.maktx,
    mseg.mblnr,
    mkpf.budat
//    mseg.budat_mkpf
//    resb.matnr,
//    makt.maktx,
//    resb.bdmng,
//    resb.meins
}
where resb.bwart = '311'
and resb.werks = $parameters.p_werks
//and rkpf.usnam = $parameters.p_uname
