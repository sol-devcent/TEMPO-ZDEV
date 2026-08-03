@AbapCatalog.sqlViewName: 'ZDMP_CDSV02'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get Process order for dumping'
define view zcdsdmp_get_order 
as select distinct from afko inner join aufk on aufk.aufnr = afko.aufnr 
                    inner join jest on jest.objnr = aufk.objnr and
                                       jest.stat  = 'I0002' and
                                       jest.inact = ' '
                    inner join tj02t on tj02t.istat = jest.stat and
                                        tj02t.spras = $session.system_language   
                    inner join afpo on afpo.aufnr = afko .aufnr and
                                       afpo.posnr = '0001'
//                    inner join resb on resb.aufnr = aufk.aufnr
    
    {
    key afko.aufnr,
    key aufk.werks,
    key afko.plnbez,
        cast(afko.gstrp as abap.char(8)) as strdate,
        aufk.objnr,
        jest.stat,
        tj02t.txt04,
        afpo.charg
//        resb.aufpl,
//        resb.aplzl
        
}
//    where afko.gstrp   = '20120201'  
//      and afko.plnbez  = '001-00-03'
//      and aufk.werks   = '0101'
    
