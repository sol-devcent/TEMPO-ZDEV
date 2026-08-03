@AbapCatalog.sqlViewName: 'ZWMS_BATCH'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Batch for WMS android'
define view ZCDS_Batch_WMS as select from mcha
left outer join mch1
    on mcha.matnr = mch1.matnr
    and mcha.charg = mch1.charg
left outer join marm
     on marm.matnr = mcha.matnr      
     {
    key mcha.matnr as material_number,
    key mcha.werks as plant,
    key mcha.charg as batch,
        cast(mch1.vfdat as abap.char(8)) as expired_date,
        cast(mch1.ersda as abap.char(8)) as create_date,
        cast(mch1.lwedt as abap.char(8)) as gr_date,
        marm.meinh,
        marm.umrez,
        marm.umren
}
