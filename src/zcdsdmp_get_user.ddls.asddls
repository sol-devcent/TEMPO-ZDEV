@AbapCatalog.sqlViewName: 'ZDMP_CDSV01'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@OData.publish: true
@EndUserText.label: 'Get user for dumping'
define view zcdsdmp_get_user with parameters p_nrp : znrp

as select from zdmpppdt001 {
    key znrp        as Nrp,
        ztitle      as Title,
        zpassword   as Password,
        werks       as Plant,
        datein      as Login_date,
        timein      as Login_time,
        dateout     as Logout_date,
        timeout     as Logout_time
}
    where znrp = $parameters.p_nrp
