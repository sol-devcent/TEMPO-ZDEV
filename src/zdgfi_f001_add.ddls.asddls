@AbapCatalog.sqlViewName: 'ZDGFI_F001_VIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZDGFI_F001_ADD'
@Metadata.ignorePropagatedAnnotations: true
define view ZDGFI_F001_ADD with parameters p_vkbur: vkbur
as select from tvbur
inner join adrc on tvbur.adrnr = adrc.addrnumber 
{
    vkbur,
    adrnr,
    city1,
    street

//    CONCAT_WITH_SPACE(street, city1, 1) as address
    
}
where vkbur = $parameters.p_vkbur
