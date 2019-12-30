$PBExportHeader$b0w_reg_pricerate1.srw
$PBExportComments$[ceusee] 서비스별 요율등록1
forward
global type b0w_reg_pricerate1 from w_a_reg_m_m
end type
end forward

global type b0w_reg_pricerate1 from w_a_reg_m_m
end type
global b0w_reg_pricerate1 b0w_reg_pricerate1

type variables
String is_priceplan		//Price Plan Code
String is_Month, is_DC, is_Time, is_Hit, is_Packet, is_Sec, is_EA
end variables

forward prototypes
public function integer wfi_get_itemcod (string as_priceplan, ref string as_itemcod[])
end prototypes

public function integer wfi_get_itemcod (string as_priceplan, ref string as_itemcod[]);String ls_itemcod
Long ll_rows

ll_rows = 0
DECLARE itemcod CURSOR FOR
				Select det.itemcod
			   From priceplandet det, itemmst item
				Where det.itemcod = item.itemcod and det.priceplan = :is_priceplan
				and item.pricetable <> (select ref_content from sysctl1t where module = 'B0' and Ref_no = 'P100');
   
	Open itemcod;
		 	Do While(True)	
			Fetch itemcod
			into :ls_itemcod;
			
			//error
			 If SQLCA.SQLCODE < 0 Then
				f_msg_sql_err(title, " Select Error(PRICEPLANDET)")
				Close itemcod;
				Return -1
			 
			 ElseIf SQLCA.SQLCODE = 100 Then
				exit;
			 End If
			 
			 ll_rows += 1
			 as_itemcod[ll_rows] = ls_itemcod
	
	Loop
CLOSE itemcod;

Return 0
end function

on b0w_reg_pricerate1.create
call super::create
end on

on b0w_reg_pricerate1.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b0w_reg_pricerate1
	Desc.	: 	서비스별 요율등록 1
	Ver.	:	1.0
	Date	: 	2002.09.24
	Programer : Choi Bo Ra(cesuee)
--------------------------------------------------------------------------*/
String ls_tmp, ls_desc, ls_data[]

//월정액 Method
ls_tmp = fs_get_control("B0", "P106" , ls_desc)
fi_cut_string(ls_tmp, ';', ls_data[])
is_Month = ls_data[1]
is_Time = ls_data[2]
is_Hit = ls_data[3]
is_DC = ls_data[4]
is_Packet = ls_data[5]
is_Sec    = ls_data[6]    //시간한도월정액
is_EA     = ls_data[7]    //판매



end event

event ue_ok;call super::ue_ok;//Service 별 요금 조회
String ls_svccod, ls_where
Long ll_row

ls_svccod = Trim(dw_cond.object.svccod[1])
If IsNull(ls_svccod) Then ls_svccod = ""
If ls_svccod = "" Then
	f_msg_info(200, Title, "서비스")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
    Return 
End If

ls_where = ""
If ls_where <> "" Then ls_where += " And "
ls_where += " svccod = '" + ls_svccod + "' "

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "Price Plan Master")
	This.Trigger Event ue_reset()		//찾기가 없으면 resert
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("itemcod")

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

//Price Plan Code Setting
dw_detail.object.priceplan[al_insert_row] = is_priceplan
dw_detail.object.fromdt[al_insert_row] = Date(fdt_get_dbserver_now())

Return 0 
end event

event type integer ue_extra_save();//Save Check
String ls_itemcod, ls_fromdt, ls_method, ls_unit, ls_unitcharge
String ls_tmp[], ls_itemcod_1[]
Long ll_rows , i, li_count, j
Dec{6} ldc_basicamt, ldc_basicrange, ldc_unitcharge
li_count = 0
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0



//Loop
For i=1 To ll_rows
	ls_itemcod = Trim(dw_detail.object.itemcod[i])
	ls_fromdt = String(dw_detail.object.fromdt[i],'yyyymmdd')
	ls_method = Trim(dw_detail.object.method[i])
	If IsNull(ls_itemcod) Then ls_itemcod = ""
	If IsNull(ls_fromdt) Then ls_fromdt = ""
	If IsNull(ls_method) Then ls_method = ""
	
	If ls_itemcod = "" Then
		f_msg_usr_err(200, Title,"품목")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("itemcod")
		Return -1
	End If
	
	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title,"적용개시일")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("fromdt")
		Return -1
	End If
	
	If ls_method = "" Then
		f_msg_usr_err(200, Title,"과금방식")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("method")
		Return -1
	End If
	
	//월정액이면 Unit 필수
	If ls_method = is_Month Then
		ls_unit = String(dw_detail.object.unit[i])
		If IsNull(ls_unit) Then ls_unit = ""
		If ls_unit = "" Then
			f_msg_usr_err(200, Title,"과금단위")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("unit")
			Return -1
		End If
		
		ls_unitcharge = String(dw_detail.object.unitcharge[i])
		If IsNull(ls_unitcharge) Then ls_unitcharge = ""
		If ls_unitcharge = ""  Or Dec(ls_unitcharge) < 0 Then
			f_msg_usr_err(200, Title,"단위당 요금")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("unitcharge")
			Return -1
		End If
	End If
	
	//금액한도월정액/시간한도월정액일 경우
	If ls_method = is_DC Or ls_method = is_Sec Then
		ldc_basicrange = dw_detail.object.basicrange[i]
		If IsNull(ldc_basicrange) Or ldc_basicrange <= 0 Then
			f_msg_usr_err(200, Title,"기본범위")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("basicrange")
			Return -1
		End If
		
		ldc_basicamt = dw_detail.object.basicamt[i]
		If IsNull(ldc_basicamt) Or ldc_basicamt <= 0 Then
			f_msg_usr_err(200, Title,"기본료")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("basicamt")
			Return -1
		End If
	End If
	
	//판매이면
	If ls_method = is_EA Then
		ls_unit = String(dw_detail.object.unit[i])
		If IsNull(ls_unit) Then ls_unit = ""
		If ls_unit = "" Then
			f_msg_usr_err(200, Title,"과금단위")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("addunit")
			Return -1
		End If
		
		ldc_unitcharge = dw_detail.object.unitcharge[i]
		If IsNull(ldc_unitcharge) Or ldc_unitcharge <= 0 Then
			f_msg_usr_err(200, Title,"단위당 요금")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("unitcharge")
			Return -1
		End If
		
	End If
	
	
	//DC한도이면
	If ls_method = is_DC Then
		ldc_basicamt = dw_detail.object.basicamt[i]
		If IsNull(ldc_basicamt) Or ldc_basicamt <= 0 Then
			f_msg_usr_err(200, Title,"기본료")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("basicamt")
			Return -1
		End If
		
		ldc_basicrange = dw_detail.object.basicrange[i]
		If IsNull(ldc_basicrange) Or ldc_basicrange <= 0 Then
			f_msg_usr_err(200, Title,"기본 범위")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("basicrange")
			Return -1
		End If
	End If
	
	ls_itemcod_1[i] = ls_itemcod

	If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[i] = gs_user_id
		dw_detail.object.updtdt[i] = fdt_get_dbserver_now()
   End If
	
Next

//해당 Priceplan에 요금 정의된 Item Code가 꼭 저장되어야 한다.
If wfi_get_itemcod(is_priceplan, ls_tmp[]) = -1 Then Return -2

For i = 1 To UpperBound(ls_tmp[])
	For j = 1 To UpperBound(ls_itemcod_1[])
		If ls_tmp[i] = ls_itemcod_1[j] Then
			li_count++
			Exit;
		End If
	Next
Next

If li_count < UpperBound(ls_tmp[]) Then
		f_msg_usr_err(3500, Title, "")
	   Return - 2
End If
Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b0w_reg_pricerate1
integer x = 37
integer y = 44
integer width = 1353
integer height = 172
string dataobject = "b0dw_cnd_reg_pricerate1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b0w_reg_pricerate1
integer x = 1541
integer y = 40
end type

type p_close from w_a_reg_m_m`p_close within b0w_reg_pricerate1
integer x = 1847
integer y = 40
end type

type gb_cond from w_a_reg_m_m`gb_cond within b0w_reg_pricerate1
integer x = 23
integer y = 4
integer width = 1394
integer height = 220
end type

type dw_master from w_a_reg_m_m`dw_master within b0w_reg_pricerate1
integer x = 23
integer y = 240
integer height = 464
string dataobject = "b0dw_cnd_pricerate1"
end type

event dw_master::ue_init;call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.priceplan_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within b0w_reg_pricerate1
integer x = 23
integer y = 740
integer height = 888
string dataobject = "b0dw_reg_pricerate1"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_svccod, ls_filter, ls_method
String ls_type
Long ll_row, i
Integer li_cnt
DataWindowChild ldc

is_priceplan = Trim(dw_master.object.priceplan[al_select_row])
ls_svccod = Trim(dw_cond.object.svccod[1])
If IsNull(is_priceplan) Then is_priceplan = ""
If IsNull(ls_svccod) Then ls_svccod = ""
ls_where = ""

If is_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "priceplan = '" + is_priceplan + "' "

End If



//Format 지정
Select decpoint
Into 	:ls_type
From priceplanmst
where priceplan = :is_priceplan;

If ls_type = "0" Then
	dw_detail.object.basicamt.Format = "#,##0"
	dw_detail.object.suspamt.Format = "#,##0"
	dw_detail.object.unitcharge.Format = "#,##0"
	dw_detail.object.basicrange.Format = "#,##0"
ElseIf ls_type = "1" Then
	dw_detail.object.basicamt.Format = "#,##0.0"
	dw_detail.object.suspamt.Format = "#,##0.0"
	dw_detail.object.unitcharge.Format = "#,##0.0"
	dw_detail.object.basicrange.Format = "#,##0.0"
ElseIf ls_type = "2" Then
	dw_detail.object.basicamt.Format = "#,##0.00"
	dw_detail.object.suspamt.Format = "#,##0.00"
	dw_detail.object.unitcharge.Format = "#,##0.00"
	dw_detail.object.basicrange.Format = "#,##0.00"
ElseIf ls_type = "3" Then
	dw_detail.object.basicamt.Format = "#,##0.000"
	dw_detail.object.suspamt.Format = "#,##0.000"
	dw_detail.object.unitcharge.Format = "#,##0.000"
	dw_detail.object.basicrange.Format = "#,##0.000"
ElseIf ls_type = "4" Then
	dw_detail.object.basicamt.Format = "#,##0.0000"
	dw_detail.object.suspamt.Format = "#,##0.0000"
	dw_detail.object.unitcharge.Format = "#,##0.0000"
	dw_detail.object.basicrange.Format = "#,##0.0000"
End If


//dw_detail 조회
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
dw_detail.SetRedraw(False)
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

//해당 Priceplan Item만 가져오게
ll_row = dw_detail.GetChild("itemcod", ldc)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
ls_filter = "priceplandet_priceplan = '" + is_priceplan + "' "
ldc.SetFilter(ls_filter)			//Filter정함
ldc.Filter()
ldc.SetTransObject(SQLCA)
ll_row =ldc.Retrieve() 
If ll_row = 0 Then 					//해당 서비스에 대한 아이템이 없는것
 f_msg_info(1000, Title, "품목")
 Return -2
ElseIf ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
Else
	dw_detail.SetColumn("fromdt")	//찾았을 경우 적용이 빨리 안되서
	dw_detail.SetColumn("itemcod")
End If

//Hidden에 감춰져있는거 하기
For i = 1 To dw_detail.RowCount()
	If This.Object.method[i] = is_Month Then This.Object.tmp[i] = "M"
	If This.Object.method[i] = is_Time Then This.Object.tmp[i] = "T"
	If This.Object.method[i] = is_Hit Then This.Object.tmp[i] = "H"
	If This.Object.method[i] = is_DC Then This.Object.tmp[i] = "D"
	If This.Object.method[i] = is_Packet Then This.Object.tmp[i] = "P"
	
	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)
Next

dw_detail.SetRedraw(True)
Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;//과금 방식이 바뀜에 따라
Long ll_null
String ls_fromdt

SetNull(ll_null)
If dwo.name = "method" Then
	//월정액
	If data = is_Month  Then 
		This.Object.tmp[row] = "M"
		
		This.Object.basicrange[row] = ll_null
		This.Object.basicamt[row]   = ll_null
		This.Object.unit[row]       = 0
		This.Object.unitcharge[row] = 0
		This.Object.suspamt[row]    = 0
	End If
	
	//시간단위
	If data = is_Time Then
		This.Object.tmp[row] = "T"
		
		This.Object.basicrange[row] = 0
		This.Object.basicamt[row]   = 0
		This.Object.unit[row]       = 0
		This.Object.unitcharge[row] = 0
		This.Object.suspamt[row]    = 0
	End If
	
	//건단위
	If data = is_Hit Then 
		This.Object.tmp[row] = "C"
		
		This.Object.basicrange[row] = 0
		This.Object.basicamt[row]   = 0
		This.Object.unit[row]       = 0
		This.Object.unitcharge[row] = 0
		This.Object.suspamt[row]    = 0
	End If
		
	//Packet단위
	If data = is_Packet Then
		This.Object.tmp[row] = "P"
		
		This.Object.basicrange[row] = 0
		This.Object.basicamt[row]   = 0
		This.Object.unit[row]       = 0
		This.Object.unitcharge[row] = 0
		This.Object.suspamt[row]    = 0
	End If
	
	//금액한도월정액
	If data = is_DC Then
		This.Object.tmp[row] = "D"
		
		This.Object.basicrange[row] = 0
		This.Object.basicamt[row]   = 0
		This.Object.unit[row]       = ll_null
		This.Object.unitcharge[row] = ll_null
		This.Object.suspamt[row]    = 0
	End If
	
	//시간한도월정액
	If data = is_Sec Then
		This.Object.tmp[row] = "S"
		
		This.Object.basicrange[row] = 0
		This.Object.basicamt[row]   = 0
		This.Object.unit[row]       = ll_null
		This.Object.unitcharge[row] = ll_null
		This.Object.suspamt[row]    = 0
	End If
	
	//판매
	If data = is_EA Then
		This.Object.tmp[row] = "E"
		
		This.Object.basicrange[row] = ll_null
		This.Object.basicamt[row]   = ll_null
		This.Object.unit[row]       = 0
		This.Object.unitcharge[row] = 0
		This.Object.suspamt[row]    = ll_null
	End If
End If
end event

type p_insert from w_a_reg_m_m`p_insert within b0w_reg_pricerate1
end type

type p_delete from w_a_reg_m_m`p_delete within b0w_reg_pricerate1
end type

type p_save from w_a_reg_m_m`p_save within b0w_reg_pricerate1
end type

type p_reset from w_a_reg_m_m`p_reset within b0w_reg_pricerate1
integer x = 1353
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b0w_reg_pricerate1
integer y = 708
end type

