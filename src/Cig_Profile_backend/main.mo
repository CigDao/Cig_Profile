import Prim "mo:prim";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import TrieMap "mo:base/TrieMap";
import List "mo:base/List";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Cycles "mo:base/ExperimentalCycles";
import Result "mo:base/Result";
import Error "mo:base/Error";
import Profile "./models/Profile";
import Follow "./models/Follow";
import TokenService "./services/TokenService";

actor class CigProfile() = this {

  type Profile = Profile.Profile;
  type Follow = Follow.Follow;

  private let cost = 100000000000;

  private stable var follows : [Follow] = [];

  private stable var profileEntries : [(Principal,Profile)] = [];
  private var profiles = HashMap.fromIter<Principal,Profile>(profileEntries.vals(), 0, Principal.equal, Principal.hash);

  system func preupgrade() {
    profileEntries := Iter.toArray(profiles.entries());
  };

  system func postupgrade() {
    profileEntries := [];
  };
  
  public query func getMemorySize(): async Nat {
      let size = Prim.rts_memory_size();
      size;
  };

  public query func getHeapSize(): async Nat {
      let size = Prim.rts_heap_size();
      size;
  };

  public query func getCycles(): async Nat {
      Cycles.balance();
  };

  public query func getProfile(member:Principal): async ?Profile {
      profiles.get(member);
  };

  public query func fetchFollowers(member:Principal): async [Follow] {
     Array.filter(follows,func(e:Follow):Bool{e.following == member});
  };

  public query func fetchFollowing(member:Principal): async [Follow] {
     Array.filter(follows,func(e:Follow):Bool{e.follower == member});
  };

  public shared({caller}) func setProfile(profile:Profile): async TokenService.TxReceipt {
    let exist = profiles.get(caller);
    var time = Time.now();
    let allowance = await TokenService.allowance(caller, Principal.fromActor(this));
    if(cost > allowance){
      return #Err(#InsufficientAllowance);
    };
    
    switch(exist){
      case(?exist){
        time := exist.createdAt;
      };
      case(null){

      }
    };

    let _profile = {
        bio = profile.bio;
        headline = profile.headline;
        socials = profile.socials;
        profileImage = profile.profileImage;
        createdAt = time;
    };

    profiles.put(caller,_profile);
    #Ok(0);
  };

  public shared({caller}) func follow(member:Principal): async TokenService.TxReceipt {
    let allowance = await TokenService.allowance(caller, Principal.fromActor(this));
    if(cost > allowance){
      return #Err(#InsufficientAllowance);
    };
    let _follow:Follow = {
      follower = caller;
      following = member;
    };

    let exist = Array.find(follows,func(e:Follow):Bool{e.follower == caller and e.following == member});
    switch(exist){
      case(?exist){

      };
      case(null){
        follows := Array.append(follows,[_follow]);
      };
    };

    #Ok(0);
  };

  public shared({caller}) func unfollow(member:Principal): async TokenService.TxReceipt {
    let allowance = await TokenService.allowance(caller, Principal.fromActor(this));
    if(cost > allowance){
      return #Err(#InsufficientAllowance);
    };
    let _follow:Follow = {
      follower = caller;
      following = member;
    };

    follows := Array.filter(follows,func(e:Follow):Bool{e.follower == caller and e.following == member});

    #Ok(0);
  };

};
