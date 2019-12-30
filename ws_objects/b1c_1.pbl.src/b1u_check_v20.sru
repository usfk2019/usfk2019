$PBExportHeader$b1u_check_v20.sru
$PBExportComments$[jsha] Check Object
forward
global type b1u_check_v20 from u_cust_a_check
end type
end forward

global type b1u_check_v20 from u_cust_a_check
end type
global b1u_check_v20 b1u_check_v20

forward prototypes
public subroutine uf_prc_check_01 ()
public subroutine uf_prc_check ()
end prototypes

public subroutine uf_prc_check_01 ();
end subroutine

public subroutine uf_prc_check ();/*-------------------------------------------------------------------------
	name	: uf_prc_check_01()
	desc.	: 저장실 필수 입력 항목 Check
	arg.	: none
			  ii_rc  -1 실패
			          0 성공
	Date	: 2003.12.10
	programer : C.BORA
--------------------------------------------------------------------------*/	

//b1w_reg_customertrouble_2
String ls_customerid, ls_troubletype, ls_receiptdt, ls_note, ls_note2, ls_customernm, ls_cid
String ls_receiupt_user, ls_responsedt, ls_closedt, ls_trouble_status, ls_modelno
String ls_admodel_yn, ls_troubleno, ls_partner, ls_priceplan, ls_requestdt
String ls_ssno, ls_cregno, ls_svccod
Long 	ll_row, i, lc_troubleno,ll_seq, ll_contractseq
DateTime ldt_receiptdt, ldt_responsedt, ldt_closedt, ldt_requestdt
String ls_troubletypea, ls_troubletypeb, ls_troubletypec
String ls_closeyn, ls_close_user, ls_restype, ls_phone
boolean lb_check

ii_rc = -2

Choose Case is_caller
		
	Case "b1w_reg_customermtrouble_v20%extra_save"

      Choose Case ii_data[1]
			Case 1
				lc_troubleno = idw_data[1].object.customer_trouble_troubleno[1]
				
				//2007-2-23 add => 고객번호, 계약번호 필수 항목 & 
				//계약번호의 CID와 고객번호와일 일치성점검 --by 정
				ls_customerid = Trim(idw_data[1].object.customer_trouble_customerid[1])
				If IsNull(ls_customerid) Then ls_customerid = ""
				If ls_customerid = "" Then
					f_msg_usr_err(200, is_title, "Customerid")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_customerid")
					Return
				End If
				ll_contractseq = idw_data[1].object.customer_trouble_contractseq[1]
				If IsNull(ll_contractseq) Then ll_contractseq = -1
				If ll_contractseq = -1 Then
					f_msg_usr_err(200, is_title, "계약번호")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_contractseq")
					Return
				End If
				
				select customerid INTO :ls_cid FROM contractmst 
				 where contractseq = :ll_contractseq ;
				
				IF ls_cid <> ls_customerid THEN
					f_msg_usr_err(9000, is_title, "계약번호의 고객번호와 입력된 고객번호가 다릅니다.")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_contractseq")
					Return
				END IF
				
				ls_customernm = Trim(idw_data[1].object.customer_trouble_customernm[1])
				If IsNull(ls_customernm) Then ls_customernm = ""
				If ls_customernm = "" Then
					f_msg_usr_err(200, is_title, "고객명")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_customernm")
					Return
				End If
				
				ls_svccod  = Trim(idw_data[1].object.customer_trouble_svccod[1])
				If IsNull(ls_svccod) Then ls_svccod = ""
				If ls_svccod = "" Then
					f_msg_usr_err(200, is_title, "대상 서비스")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_svccod")
					Return
				End If
				
				ls_priceplan  = Trim(idw_data[1].object.customer_trouble_priceplan[1])
				If IsNull(ls_priceplan) Then ls_priceplan = ""
				If ls_priceplan = "" Then
					f_msg_usr_err(200, is_title, "상품(가격정책)")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_priceplan")
					Return
				End If
				
				ls_troubletypec  = Trim(idw_data[1].object.troubletypeb_troubletypec[1])
				If IsNull(ls_troubletypec) Then ls_troubletypec = ""
				If ls_troubletypec = "" Then
					f_msg_usr_err(200, is_title, "민원유형 대분류")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("troubletypeb_troubletypec")
					Return
				End If
				
				ls_troubletypeb  = Trim(idw_data[1].object.troubletypea_troubletypeb[1])
				If IsNull(ls_troubletypeb) Then ls_troubletypeb = ""
				If ls_troubletypeb = "" Then
					f_msg_usr_err(200, is_title, "민원유형 중분류")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("troubletypea_troubletypeb")
					Return
				End If

				ls_troubletypea  = Trim(idw_data[1].object.troubletypemst_troubletypea[1])
				If IsNull(ls_troubletypea) Then ls_troubletypea = ""
				If ls_troubletypea = "" Then
					f_msg_usr_err(200, is_title, "민원유형 소분류")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("troubletypemst_troubletypea")
					Return
				End If
				
				ls_troubletype  = Trim(idw_data[1].object.customer_trouble_troubletype[1])
				If IsNull(ls_troubletype) Then ls_troubletype = ""
				If ls_troubletype = "" Then
					f_msg_usr_err(200, is_title, "민원유형")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_troubletype")
					Return
				End If
				
				ls_partner = Trim(idw_data[1].object.customer_trouble_partner[1])
				If IsNull(ls_partner) Then ls_partner = ""
				If ls_partner = "" Then
					f_msg_usr_err(200, is_title, "민원처리처")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_partner")
					Return
				End If
				
				ls_trouble_status  = Trim(idw_data[1].object.customer_trouble_trouble_status[1])
				If IsNull(ls_trouble_status) Then ls_trouble_status = ""
				If ls_trouble_status = "" Then
					f_msg_usr_err(200, is_title, "처리상태")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_trouble_status")
					Return
				End If
				
				ldt_receiptdt  = idw_data[1].object.customer_trouble_receiptdt[1]
				ls_receiptdt = String(ldt_receiptdt, 'YYYYMMDD')
				If IsNull(ls_receiptdt) Then ls_receiptdt = ""
				If ls_receiptdt = "" Then
					f_msg_usr_err(200, is_title, "접수일자")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_receiptdt")
					Return
				End If
				
				ldt_closedt    = idw_data[1].object.customer_trouble_closedt[1]
				ls_closedt     = String(ldt_closedt, 'YYYYMMDD')
				ldt_requestdt  = idw_data[1].object.customer_trouble_requestdt[1]
				ls_requestdt   = String(ldt_requestdt, 'YYYYMMDD')
				
				////// 날짜 체크
				If ls_receiptdt <> "" Then 
					lb_check = fb_chk_stringdate(ls_receiptdt)
					If Not lb_check Then 
						f_msg_usr_err(210, is_Title, "'접수일자의 날짜 포맷 오류입니다.")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("customer_trouble_receiptdt")
						Return
					End If
				End if
						
				If ls_receiptdt <> "" and ls_requestdt <> "" Then
					If ls_receiptdt > ls_requestdt Then
						f_msg_usr_err(221, is_Title, "접수일자가 처리완료일자보다 작아야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("customer_trouble_receiptdt")
						Return
					End if
				End if
				
				ls_note  = Trim(idw_data[1].object.customer_trouble_trouble_note[1])
				If IsNull(ls_note) Then ls_note = ""
				If ls_note = "" Then
					f_msg_usr_err(200, is_title, "접수내역")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_trouble_note")
					Return
				End If
				
			Case 2
				
				lc_troubleno = idw_data[1].object.troubl_response_troubleno[1]
				
				ll_row = idw_data[1].RowCount()
				For i =1 To ll_row
					ls_responsedt = String(idw_data[1].object.troubl_response_responsedt[i], 'YYYYMMDD')
					If IsNull(ls_responsedt) Then ls_responsedt = ""
					If ls_responsedt = "" Then
						f_msg_usr_err(200, is_title, "처리일자")
						idw_data[1].SetRow(i)
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("troubl_response_responsedt")
						Return
					End If
					
					ls_trouble_status  = Trim(idw_data[1].object.troubl_response_trouble_status[i])
					If IsNull(ls_trouble_status) Then ls_trouble_status = ""
					If ls_trouble_status = "" Then
						f_msg_usr_err(200, is_title, "처리상태")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("troubl_response_trouble_status")
						Return
					End If
					
		       Next
				 				
			Case 3
				ls_closedt    = string(idw_data[1].object.customer_trouble_closedt[1],'yyyymmddhh24miss')
				ls_closeyn    = Trim(idw_data[1].object.customer_trouble_closeyn[1])
				ls_close_user = Trim(idw_data[1].object.customer_trouble_close_user[1])
				ls_restype    = Trim(idw_data[1].object.customer_trouble_restype[1])
				ls_partner    = Trim(idw_data[1].object.close_partner[1])
				ls_phone      = Trim(idw_data[1].object.customer_trouble_phone[1])
				ls_note       = Trim(idw_data[1].object.close_note[1])
				
				If fs_snvl(ls_closedt, " ") = " " Then
					f_msg_usr_err(200, is_title, "처리완료일")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_closedt")
					Return
				End If
				
				If fs_snvl(ls_closeyn, " ") = " " Then
					f_msg_usr_err(200, is_title, "처리완료")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_closeyn")
					Return
				End If
				
				If fs_snvl(ls_close_user, " ") = " " Then
					f_msg_usr_err(200, is_title, "완료처리자")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_close_user")
					Return
				End If
				
//				If fs_snvl(ls_restype, " ") = " " Then
//					f_msg_usr_err(200, is_title, "조치유형")
//					idw_data[1].SetFocus()
//					idw_data[1].SetColumn("customer_trouble_restype")
//					Return
//				End If
				
				If fs_snvl(ls_partner, " ") = " " Then
					f_msg_usr_err(200, is_title, "완료 Shop")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("close_partner")
					Return
				End If
				
				If fs_snvl(ls_note, " ") = " " Then
					f_msg_usr_err(200, is_title, "조치결과내역")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("close_note")
					Return
				End If
				
		End Choose
				
		
End Choose

ii_rc = 0 


end subroutine

on b1u_check_v20.create
call super::create
end on

on b1u_check_v20.destroy
call super::destroy
end on

