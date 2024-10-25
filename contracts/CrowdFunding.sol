// // // SPDX-License-Identifier: MIT


pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 goal;
        uint256 deadline;
        uint256 amountCollected;
        bool paidOut; 
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => address[]) public donators;
    mapping(uint256 => uint256[]) public donations;
    uint256 public numberOfCampaigns = 0;

    event CampaignCreated(uint256 id, address owner, string title, uint256 goal, uint256 deadline);
    event Funded(uint256 id, address donator, uint256 amount);
    event Withdrawn(uint256 id, address owner, uint256 amount);

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _goal,
        uint256 _deadline
    ) public returns (uint256) {
        require(_deadline > block.timestamp, "The deadline should be a date in the future.");

        Campaign storage campaign = campaigns[numberOfCampaigns];
        campaign.owner = msg.sender;
        campaign.title = _title;
        campaign.description = _description;
        campaign.goal = _goal;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.paidOut = false; 

        emit CampaignCreated(numberOfCampaigns, msg.sender, _title, _goal, _deadline);

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function fundCampaign(uint256 _id) public payable {
        require(_id < numberOfCampaigns, "Invalid campaign ID."); 
        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];
        require(block.timestamp < campaign.deadline, "The campaign deadline has passed.");
        require(amount > 0, "You must send some ether.");

        donators[_id].push(msg.sender);
        donations[_id].push(amount);
        
        campaign.amountCollected += amount;

        emit Funded(_id, msg.sender, amount);
    }

    function withdraw(uint256 _id) public {
        require(_id < numberOfCampaigns, "Invalid campaign ID."); 
        Campaign storage campaign = campaigns[_id];
        
        require(msg.sender == campaign.owner, "Only the campaign owner can withdraw funds.");
        require(!campaign.paidOut, "Funds already withdrawn.");
        require(block.timestamp >= campaign.deadline, "Campaign deadline not reached yet.");
        require(campaign.amountCollected >= campaign.goal, "Campaign target not met.");

        uint256 payoutAmount = campaign.amountCollected;
        campaign.amountCollected = 0; 
        campaign.paidOut = true; 

        (bool sent, ) = payable(campaign.owner).call{value: payoutAmount}("");
        require(sent, "Failed to send funds to the campaign owner.");

        emit Withdrawn(_id, campaign.owner, payoutAmount);
    }
}