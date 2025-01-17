import 'package:cryptoplease/core/amount.dart';
import 'package:cryptoplease/core/currency.dart';
import 'package:cryptoplease/core/tokens/token.dart';
import 'package:cryptoplease/features/outgoing_transfer/bl/create_outgoing_transfer_bloc/ft/bloc.dart';
import 'package:cryptoplease/features/outgoing_transfer/bl/outgoing_payment.dart';
import 'package:decimal/decimal.dart';
import 'package:dfunc/dfunc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_pay_bloc.freezed.dart';
part 'request_pay_event.dart';
part 'request_pay_state.dart';

typedef _Event = RequestPayEvent;
typedef _State = RequestPayState;
typedef _EventHandler = EventHandler<_Event, _State>;
typedef _Emitter = Emitter<_State>;

class RequestPayBloc extends Bloc<_Event, _State> {
  RequestPayBloc({
    required Map<Token, Amount> balances,
  })  : _balances = balances,
        super(const RequestPayState(amount: _defaultAmount)) {
    on<_Event>(_eventHandler);
  }

  static const _defaultAmount = CryptoAmount(
    value: 0,
    currency: CryptoCurrency(token: Token.usdc),
  );

  final Map<Token, Amount> _balances;

  _EventHandler get _eventHandler => (event, emit) => event.map(
        amountUpdated: (event) => _onAmountUpdated(event, emit),
      );

  void _onAmountUpdated(_AmountUpdated event, _Emitter emit) {
    emit(state.copyWith(amount: state.amount.copyWithDecimal(event.amount)));
  }

  Either<ValidationError, void> validate() {
    final token = state.amount.token;
    final userBalance = _balances[token] ??
        Amount.zero(currency: Currency.crypto(token: token));

    if (userBalance < state.amount) {
      return Either.left(
        ValidationError.insufficientFunds(
          balance: userBalance,
          currentAmount: state.amount,
        ),
      );
    }

    var feeBalance =
        _balances[Token.sol] ?? Amount.zero(currency: Currency.sol);
    if (token == Token.sol) {
      feeBalance -= state.amount;
    }

    if (feeBalance < state.fee) {
      return Either.left(ValidationError.insufficientFee(state.fee));
    }

    return const Either.right(null);
  }
}
