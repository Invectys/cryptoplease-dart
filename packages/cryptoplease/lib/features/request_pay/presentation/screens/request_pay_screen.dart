import 'package:cryptoplease/app/components/token_fiat_input_widget/enter_amount_keypad.dart';
import 'package:cryptoplease/app/screens/authenticated/components/navigation_bar/navigation_bar.dart';
import 'package:cryptoplease/core/presentation/dialogs.dart';
import 'package:cryptoplease/features/request_pay/bl/request_pay_bloc.dart';
import 'package:cryptoplease/features/request_pay/presentation/components/qr_scanner_appbar.dart';
import 'package:cryptoplease/features/request_pay/presentation/components/request_pay_header.dart';
import 'package:cryptoplease/features/request_pay/presentation/components/token_info_widget.dart';
import 'package:cryptoplease/features/request_pay/presentation/request_pay_flow.dart';
import 'package:cryptoplease/l10n/l10n.dart';
import 'package:cryptoplease_ui/cryptoplease_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestPayScreen extends StatefulWidget {
  const RequestPayScreen({Key? key}) : super(key: key);

  @override
  State<RequestPayScreen> createState() => _ScreenState();
}

class _ScreenState extends State<RequestPayScreen> {
  late final RequestPayRouter _router;
  late final TextEditingController _amountController;

  @override
  void initState() {
    _router = context.read<RequestPayRouter>();
    _amountController = TextEditingController();
    _amountController.addListener(_updateValue);
    super.initState();
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateValue);
    super.dispose();
  }

  void _updateValue() {
    final value = _amountController.text;
    _router.onAmountUpdate(value);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: QrScannerAppBar(
        onQrScanner: () => showWarningDialog(
          context,
          title: context.l10n.scanQRTitle,
          message: context.l10n.comingSoon,
        ),
      ),
      body: BlocBuilder<RequestPayBloc, RequestPayState>(
        builder: (context, state) => Column(
          children: [
            RequestPayHeader(
              inputController: _amountController,
              token: state.amount.currency.token,
            ),
            const SizedBox(height: 16),
            InfoWidget(message: context.l10n.usdcExplanation),
            const SizedBox(height: 8),
            Flexible(
              flex: 3,
              child: LayoutBuilder(
                builder: (context, constraints) => EnterAmountKeypad(
                  height: constraints.maxHeight,
                  width: width,
                  controller: _amountController,
                  maxDecimals: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Flexible(
                    child: CpButton(
                      text: context.l10n.receive,
                      minWidth: width,
                      onPressed: _router.onRequest,
                      size: CpButtonSize.big,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Flexible(
                    child: CpButton(
                      text: context.l10n.pay,
                      minWidth: width,
                      onPressed: _router.onPay,
                      size: CpButtonSize.big,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: cpNavigationBarheight + 16),
          ],
        ),
      ),
    );
  }
}
