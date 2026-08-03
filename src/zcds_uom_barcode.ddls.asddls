@AbapCatalog.sqlViewName: 'ZWMS_UOM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Konversi UOM dan Barcode'
define view zcds_uom_barcode as select from mara
left outer join marm
    on mara.matnr = marm.matnr
left outer join makt
    on mara.matnr = makt.matnr and
       makt.spras = 'E' 
left outer join mean
    on marm.matnr = mean.matnr 
    and marm.meinh = mean.meinh  
left outer join marc on marc.matnr = mara.matnr 
{
    key marc.werks as plant,
    key mara.matnr as material_number,
        makt.maktx as material_description,
        mara.xchpf as batch_management,
        mara.meins as uom_satuan,
        marm.meinh as uom_alternative,
        cast(marm.umren as abap.char(7)) as uom_number_conversi,
        cast(marm.umrez as abap.char(7)) as uom_conversi,
        mean.ean11 as barcode,
        mean.hpean as main_ean,
        mean.eantp as ean_category
    
} where marc.werks = '0200' and marc.lvorm = ' ' //and mean.ean11 <> ' '
