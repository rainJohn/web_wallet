angular.module("app").controller "DelegatesController", ($scope, $location, $state, $q, Growl, Blockchain, Wallet, RpcService, Info) ->
    $scope.active_delegates = Blockchain.active_delegates
    $scope.inactive_delegates = Blockchain.inactive_delegates
    $scope.approved_delegates = Wallet.approved_delegates
    $scope.avg_act_del_pay_rate = Blockchain.avg_act_del_pay_rate
    $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate
    $scope.p =
        currentPage: 0
        pageSize: 100
        numberOfPages: 0
    $scope.p.numberOfPages = Math.ceil($scope.inactive_delegates.length / $scope.p.pageSize)

    $q.all([Wallet.refresh_accounts(), Blockchain.refresh_delegates()]).then ->
        $scope.active_delegates = Blockchain.active_delegates
        $scope.inactive_delegates = Blockchain.inactive_delegates
        $scope.approved_delegates = Wallet.approved_delegates
        $scope.avg_act_del_pay_rate = Blockchain.avg_act_del_pay_rate
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate
        $scope.p.numberOfPages = Math.ceil($scope.inactive_delegates.length / $scope.p.pageSize)

        $scope.approved_delegates_list = []
        angular.forEach Wallet.approved_delegates, (value, key) ->
            delegate = Blockchain.all_delegates[key]
            if delegate
                $scope.approved_delegates_list.push delegate
            else
                console.log "cannot find approved delegate #{key}"

    $scope.$watch ()->
        Info.info
    , ()->
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate
    ,true
    ###
    Info.refresh_info().then ->
        $scope.blockchain_delegate_pay_rate = Info.info.blockchain_delegate_pay_rate
        console.log('Info.info.blockchain_delegate_pay_rate',Info.info.blockchain_delegate_pay_rate)
    ###

    Blockchain.get_asset(0).then (asset_type) =>
        $scope.current_xts_supply = asset_type.current_share_supply

    $scope.toggleVoteUp = (name) ->
        approve = !Wallet.approved_delegates[name]
        Wallet.approve_delegate(name, approve).then ->
            $scope.trust_level = approve

    $scope.unvoteAll = ->
        angular.forEach Wallet.approved_delegates, (value, key) ->
            Wallet.approve_delegate(key, false)
