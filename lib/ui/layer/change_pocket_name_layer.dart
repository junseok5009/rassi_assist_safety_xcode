import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pocket.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';

class ChangePocketNameLayer extends StatefulWidget {
  final Pocket? pocket;

  const ChangePocketNameLayer({this.pocket, Key? key}) : super(key: key);

  //const ChangePocketNameLayer({super.key});

  @override
  State<ChangePocketNameLayer> createState() => _ChangePocketNameLayerState();
}

class _ChangePocketNameLayerState extends State<ChangePocketNameLayer> {
  String _pocketName = '';
  final _texteditController = TextEditingController();

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _texteditController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pocketName = widget.pocket!.pktName;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.black,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 24,
                    onPressed: () {
                      if (context != null && context.mounted) {
                        Navigator.pop(
                          context,
                          CustomNvRouteResult.cancel,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  '포켓 이름 변경',
                  style: TStyle.title18T,
                ),
                const SizedBox(
                  height: 40,
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 36,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                      left: 5,
                    ),
                    child: TextField(
                      controller: _texteditController,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      cursorWidth: 1.6,
                      cursorHeight: 24,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.black,
                        focusColor: Colors.black,
                        //border: InputBorder(borderSide: BorderSide()),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: RColor.greyTitle_cdcdcd,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: RColor.greyTitle_cdcdcd,
                            width: 1.5,
                          ),
                        ),
                        counterText: '',
                        hintText: widget.pocket!.pktName,
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: RColor.greyTitle_cdcdcd,
                          letterSpacing: 0.3,
                        ),
                      ),
                      scrollPadding: const EdgeInsets.only(bottom: 100),
                      onChanged: (value) {
                        _pocketName = value;
                      },
                      maxLines: 1,
                      //maxLength: 13,
                      textInputAction: TextInputAction.done,
                      cursorColor: Colors.black,
                      //keyboardType: TextInputType.number,
                      /*inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ], */ // On
                    ),
                  ),
                ),
                Center(
                  child: InkWell(
                    onTap: () async {
                      if (_pocketName.isEmpty) {
                        commonShowToastCenter('포켓 이름을 입력해 주십시오.');
                      } else if (_pocketName.length > 19) {
                        commonShowToastCenter('포켓 이름은 20글자를 넘을 수 없습니다.');
                      } else if (_pocketName == widget.pocket!.pktName) {
                        commonShowToastCenter('현재 포켓 이름과 변경하려는 포켓 이름이 같습니다.');
                      } else {
                        bool result = await Provider.of<PocketProvider>(context,
                                listen: false)
                            .changeNamePocket(
                                Pocket(widget.pocket!.pktSn, _pocketName));

                        if (context.mounted) {
                          if (result) {
                            Navigator.pop(
                              context,
                              CustomNvRouteResult.refresh,
                            );
                          } else {
                            Navigator.pop(context, CustomNvRouteResult.fail);
                            CommonPopup.instance.showDialogBasic(context, '안내',
                                CommonPopup.dbEtcErroruserCenterMsg);
                          }
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(
                        top: 40,
                      ),
                      decoration: UIStyle.boxRoundFullColor25c(
                        RColor.mainColor,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '변경하기',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
