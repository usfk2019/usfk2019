$PBExportHeader$ssrt_reg_ktf_payment.srw
$PBExportComments$[1hera] KTF Payment
forward
global type ssrt_reg_ktf_payment from w_a_reg_m
end type
type dw_desc from datawindow within ssrt_reg_ktf_payment
end type
type p_saveas from u_p_saveas within ssrt_reg_ktf_payment
end type
end forward

global type ssrt_reg_ktf_payment from w_a_reg_m
integer width = 3351
integer height = 1852
event ue_saveas ( )
dw_desc dw_desc
p_saveas p_saveas
end type
global ssrt_reg_ktf_payment ssrt_reg_ktf_payment

type variables
string is_select_cod
end variables

event ue_saveas();
f_excel_ascii1(dw_detail, Title)
end event

on ssrt_reg_ktf_payment.create
int iCurrent
call super::create
this.dw_desc=create dw_desc
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_desc
this.Control[iCurrent+2]=this.p_saveas
end on

on ssrt_reg_ktf_payment.destroy
call super::destroy
destroy(this.dw_desc)
destroy(this.p_saveas)
end on

event ue_ok();call super::ue_ok;String 	ls_where, &
			ls_payid,	ls_validkey,	ls_ym_fr,	ls_ym_to
Long 		ll_row

ls_ym_fr 	= String(dw_cond.object.ym_fr[1], 'yyyymm')
ls_ym_to 	= String(dw_cond.object.ym_to[1], 'yyyymm')
ls_payid 	= Trim(dw_cond.object.payid[1])
ls_validkey = Trim(dw_cond.object.validkey[1])

If IsNull(ls_ym_fr) 		Then ls_ym_fr 	= ""
If IsNull(ls_ym_to) 		Then ls_ym_to 	= ""
If IsNull(ls_payid) 		Then ls_payid 	= ""
If IsNull(ls_validkey)	Then ls_validkey 	= ""

IF ls_ym_fr = "" THEN
	f_msg_info(200, This.Title, "Transaction Date- From")
	dw_cond.SetColumn("ym_fr")
	dw_cond.SetFocus()
	return	
END IF
IF ls_ym_to = "" THEN
	f_msg_info(200, This.Title, "Transaction Date- To")
	dw_cond.SetColumn("ym_to")
	dw_cond.SetFocus()
	return	
END IF

ls_where = ""

If ls_ym_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(A.TRDT, 'yyyymm') >= '" + ls_ym_fr + "' "
End If
//
If ls_ym_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(A.TRDT, 'yyyymm') <= '" + ls_ym_to + "' "
End If
If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "A.payid = '" + ls_payid + "' "
End If
If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "A.validkey = '" + ls_validkey + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If


end event

event type integer ue_extra_save();Long		ll_row, i

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0
//
//For i = 1 To ll_row
//  //Update한 log 정보
//   If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
//		dw_detail.object.updt_user[i] 	= gs_user_id
//		dw_detail.object.updtdt[i] 		= fdt_get_dbserver_now()
//   End If
//Next
Return 0

end event

event type integer ue_reset();call super::ue_reset;//초기화
dw_cond.SetColumn("filename")
dw_cond.Object.trdt[1] =  fdt_get_dbserver_now()
dw_cond.Object.ym_fr[1] =  fdt_get_dbserver_now()
dw_cond.Object.ym_to[1] =  fdt_get_dbserver_now()


Return 0
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	ssrt_reg_ktf_payment
	Desc.	: 	KTF PAYMENTUpload
	Ver.	:	1.0
	Date	: 	2006.12.29
	Programer : Cho Kyung Bok [ 1hera ]
--------------------------------------------------------------------------*/
dw_desc.Hide()

end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_ktf_payment
integer x = 46
integer y = 40
integer width = 2080
integer height = 492
string dataobject = "ssrt_cnd_reg_ktf_payment"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::buttonclicked;call super::buttonclicked;String 	ls_fileName, ls_trdt, ls_payid, 	ls_customernm
Int		li_fileId, 		li_jj, 		li_rtn	, li_amt_cnt
datetime ld_trdt
Long		ll_pos1, ll_pos2,		ll_row, ll_total,	ll_desc_row, 	ll_ktfid
String 	ls_temp,	ls_ref_desc, ls_status, ls_txt[], &
			ls_validkey,	ls_ktfid, ls_data, 	ls_col1, ls_col2, &
			ls_desc[]

CHOOSE CASE	dwo.Name
	CASE "load"		//파일처리
		this.AcceptText()
		dw_detail.Reset()
		
		ls_fileName = Trim(This.Object.filename[1])
		ld_trdt		= dateTime( date(This.Object.trdt[1]), time('00:00:00') )
		ls_trdt		= String(This.Object.trdt[1], 'yyyymmdd')
		IF isNull(ls_fileName) 	THEN ls_fileName 	= ""
		IF isNull(ls_trdt) 		THEN ls_trdt		= ""
		
		IF ls_fileName = "" THEN
			f_msg_info(200, This.Title, "File")
			This.SetFocus()
			RETURN 0
		END IF
		IF ls_trdt = "" THEN
			f_msg_info(200, This.Title, "Transaction Date")
			This.SetFocus()
			RETURN 0
		END IF
		
		li_fileId = FileOpen(ls_fileName, LineMode!) //한줄씩 읽어오기
		If(IsNull(li_fileId) or li_fileId < 0) THEN
			f_msg_usr_err(200, Title, "파일열기 실패")
			This.SetColumn("filename")
			this.setFocus()
			RETURN 0
		End If
		
		//Status
		ls_status 			= fs_get_control("B0", "P223", ls_ref_desc)
		If ls_status 		= "" Then Return

		ll_desc_row =  dw_desc.Retrieve()
		FOR li_jj = 1 to ll_desc_row
			ls_desc[li_jj] = Trim(dw_desc.Object.codenm[li_jj])
		NEXT
		//==========================================================
		//End of File(return -100)
		//==========================================================
		DO UNTIL( FileRead(li_fileId,	ls_data) = -100 )
			IF( trim(ls_data) <> "") THEN
				ll_total ++
				This.object.t_msg.Text 	= 'Data Load...  ' + String(ll_total)
				
				li_rtn = fi_cut_string(ls_data, "~t", ls_txt[])
				
				// sysctl에 설정된 갯수와 파일의 항목 갯수를 비교 - 20071025 - hcjung
				IF ll_desc_row < li_rtn - 2 THEN
				    f_msg_usr_err(200, Title, "시스템 코드와 항목수가 다릅니다.")
                This.SetColumn("filename")
			       This.setFocus()
			       RETURN 0
			   END IF
				
				ls_validkey = Trim(ls_txt[2])
				ll_ktfid 	= Long(ls_txt[1]) //KTF CustomerID
				li_amt_cnt	= 0
				
				ls_payid = ''
				ls_customernm = ''
				
				SELECT A.payid, a.customernm INTO :ls_payid, :ls_customernm
				  FROM customerm A, validinfo B
				 WHERE B.validkey = :ls_validkey 
				   AND B.status   = :ls_status
				   AND B.customerid = A.customerid;
				
				IF IsNull(ls_payid) OR sqlca.sqlcode < 0 THEN ls_payid = ''
				
				ll_row = dw_detail.InsertRow(0)
				dw_detail.Object.validkey[ll_row]			= ls_validkey
				dw_detail.Object.trdt[ll_row] 				= ld_trdt
				dw_detail.Object.ktf_customerid[ll_row] 	= ll_ktfid
				dw_detail.Object.payid[ll_row] 				= ls_payid
				dw_detail.Object.customernm[ll_row]			= ls_customernm
				dw_detail.Object.payment_yn[ll_row] 		= 'N'
				dw_detail.object.crt_user[ll_row] 			= gs_user_id
				dw_detail.object.crtdt[ll_row]				= fdt_get_dbserver_now()
				dw_detail.object.pgm_id[ll_row] 				= gs_pgm_id[gi_open_win_no]	
				IF li_rtn > 32 THEN li_rtn =  32 
				FOR li_jj =  1 to li_rtn -  2
					ls_col1	= 'tramt' + RightA('00' + String(li_jj), 2)
					ls_col2	= 'trdesc' + RightA('00' + String(li_jj), 2)
					dw_detail.SetItem(ll_row, ls_col1, Long(ls_txt[li_jj + 2]) )
					dw_detail.SetItem(ll_row, ls_col2, ls_desc[li_jj] )
					li_amt_cnt ++
				NEXT
				IF li_rtn < 32 THEN
					FOR li_jj = 1 to 32 - li_rtn
						
						ls_col1	= 'tramt'  + RightA('00' + String(li_amt_cnt + li_jj), 2)
						ls_col2	= 'trdesc' + RightA('00' + String(li_amt_cnt + li_jj), 2)
						dw_detail.SetItem(ll_row, ls_col1, 0 )
						dw_detail.SetItem(ll_row, ls_col2, "" )
					NEXT
				END IF
			END IF
		LOOP
		This.object.t_msg.Text 	= ""
		FileClose(li_fileId) //파일닫기
		//마지막 row로 간다.
		dw_detail.ScrollToRow(ll_Row)
		dw_detail.AcceptText()

		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		p_ok.TriggerEvent("ue_disable")		
		
	CASE "search"	//파일찾기
		string pathName, fileName

		Int value

		value = GetFileOpenName("Select File", &
				+ pathName, fileName, "TXT", &
				+ "Text Files (*.TXT),*.TXT")

		IF value = 1 THEN
			This.Object.filename[1] = pathName
		END IF
		
END CHOOSE
end event

type p_ok from w_a_reg_m`p_ok within ssrt_reg_ktf_payment
integer x = 2217
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_ktf_payment
integer x = 2519
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_ktf_payment
integer x = 27
integer width = 2130
integer height = 556
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_ktf_payment
boolean visible = false
integer x = 315
integer y = 1628
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_ktf_payment
boolean visible = false
integer x = 23
integer y = 1628
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_ktf_payment
integer x = 608
integer y = 1620
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_ktf_payment
integer x = 27
integer y = 572
integer width = 3264
integer height = 1012
string dataobject = "ssrt_reg_ktf_payment"
end type

event dw_detail::constructor;call super::constructor;//손모양을 막는다.
dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::doubleclicked;call super::doubleclicked;String 	ls_payid, 		ls_trdt, ls_validkey, ls_customernm, ls_desc[], ls_txt
String	ls_col1, 		ls_col2
DEC{2}	lc_charge[], 	lc_tmp
Long 		ll_jj
date		ld_trdt
If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If



ls_payid 		= Trim(This.object.payid[row])
ld_trdt  		= date(This.object.trdt[row])
ls_validkey  	= Trim(This.object.validkey[row])
ls_customernm	= trim(This.object.Customernm[row])

FOR ll_jj = 1 to 30
	ls_col1	= 'tramt' + RightA('00' + String(ll_jj), 2)
	ls_col2	= 'trdesc' + RightA('00' + String(ll_jj), 2)
	ls_txt 	= Trim(this.GetItemString(row, ls_col2))
	lc_tmp 	= this.GetItemNumber(row, ls_col1)
	IF IsNull(ls_txt) then ls_txt = ''
	IF IsNull(lc_tmp) then lc_tmp = 0
	
	ls_desc[ll_jj] 	= ls_txt
	lc_charge[ll_jj] 	= lc_tmp
NEXT
iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "KTF Payment Request"
iu_cust_msg.is_grp_name = "KTF Payment Request"
iu_cust_msg.is_pgm_id 	= gs_pgm_id[gi_open_win_no]
iu_cust_msg.ib_data[1]  = True
iu_cust_msg.id_data[1]  	= ld_trdt
iu_cust_msg.is_data2[1]  	= ls_payid
iu_cust_msg.is_data2[2] 	= ls_customernm
iu_cust_msg.is_data2[3] 	= ls_validkey
iu_cust_msg.is_data[] 		= ls_desc[]
iu_cust_msg.ic_data[] 		= lc_charge[]
 
OpenWithParm(ssrt_reg_ktf_payment_pop, iu_cust_msg)

end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_ktf_payment
integer x = 1166
integer y = 1620
end type

type dw_desc from datawindow within ssrt_reg_ktf_payment
integer x = 2185
integer y = 408
integer width = 672
integer height = 132
integer taborder = 11
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_reg_ktf_desc"
boolean border = false
boolean livescroll = true
end type

event constructor;This.SetTransObject(sqlca)
end event

type p_saveas from u_p_saveas within ssrt_reg_ktf_payment
integer x = 2222
integer y = 164
boolean bringtotop = true
end type

