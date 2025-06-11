import {
    ISMAManagerAdmin, 
    ISMAAddressProvider, 
    IERC20, 
    IManagementLogic, 
    IManagementRegistry
} from "./interfaces/SMAInterfaces.sol";

contract RevenuePool {
    address public smaAddressProvider;
    uint256 public subscriptionDepositReserves;
    uint256 public deployFeeDepositsReserves;
    uint256 public investFeeTotalReserves;
    uint256 public totalReserves;

    mapping(address => uint256) public investFeeReservesPerToken;

    constructor(address _smaAddressProvider) {
        smaAddressProvider = _smaAddressProvider;
    }

    function depositSubscription(address _client) public payable {
        // TODO: Implement deposit logic
        address managerAdminAddress = ISMAAddressProvider(smaAddressProvider).getSMAManagerAdmin();
        address payTokenAddress = ISMAManagerAdmin(managerAdminAddress).getPayToken();

        uint256 subscriptionFee = ISMAManagerAdmin(managerAdminAddress).getSubscriptionFee();

        IERC20(payTokenAddress).transferFrom(_client, address(this), subscriptionFee);

        subscriptionDepositReserves += subscriptionFee;
        totalReserves += subscriptionFee;
    }

    function depositDeployFee() public payable {
        // TODO: Implement deposit logic
    }

    function depositInvestFee(address _token, uint256 _amount) public {
        // TODO: Implement deposit logic
    }

    function depositInvestFee() public payable {
        // TODO: Implement deposit logic
    }
    function deposit() public payable {
        // TODO: Implement deposit logic
    }

    function withdraw() public {
        // TODO: Implement withdraw logic
    }
}