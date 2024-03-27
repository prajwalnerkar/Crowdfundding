// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract CrowdFundding{
    mapping(address=>uint)public contributours;
    address public manager;
    uint public minmumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOFcontributours;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) votors;
    }
    mapping (uint=>Request)public request;
    uint public numRequest;

    constructor(uint _target, uint _deadline){
        target = _target;
        deadline=block.timestamp+_deadline;
        minmumContribution=100 wei;
        manager=msg.sender;
    }
    function sendEth() public payable {
    require(block.timestamp < deadline,"Deadline has oassed");
    require(msg.value >= minmumContribution,"Minimum Contrbution is not met");

    if(contributours[msg.sender]==0){
        noOFcontributours++;
    }
    contributours[msg.sender]+=msg.value;
    raisedAmount+=msg.value;
}
    function getContractBalance() public view returns(uint){
        return  address(this).balance;
    }
    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"You are not eligible for refund");
        require((contributours[msg.sender]>0));
        address payable user=payable (msg.sender);
        user.transfer(contributours[msg.sender]);
        contributours[msg.sender]=0;

    }
        modifier onlyManager(){
            require(msg.sender==manager,"Only manager can call this fuction");
            _;
        }
        function createRequest(string memory _description,address payable _recipient,uint _value)public onlyManager{
            Request storage newRequest = request[numRequest];
            numRequest++;
            newRequest.description=_description;
            newRequest.recipient=_recipient;
            newRequest.value=_value;
            newRequest.completed=false;
            newRequest.noOfVoters=0;
        }
        function voteRequest(uint _requesNo)public {
            require(contributours[msg.sender]>0,"You must be contributor");
            Request storage thisRequest=request[_requesNo];
            require(thisRequest.votors[msg.sender]==false,"You already voted");
            thisRequest.votors[msg.sender]=true;
            thisRequest.noOfVoters++;
        }
        function makePayment(uint _requestNo)public onlyManager{
            require(raisedAmount>=target);
            Request storage thisRequest=request[_requestNo];
            require(thisRequest.completed==false,"The reaquest has been completed");
            require(thisRequest.noOfVoters > noOFcontributours/2,"Majority does not support");
            thisRequest.recipient.transfer(thisRequest.value);
            thisRequest.completed=true;
        }
}