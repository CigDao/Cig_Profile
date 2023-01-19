import Time "mo:base/Time";

module {
    public type Profile = {
        username:Text;
        bio:Text;
        headline:Text;
        socials:[Social];
        profileImage:Text;
        banner:Text;
        createdAt:Time.Time;
    };

    public type Social = {
        #twitter:Text;
        #dscvr:Text;
        #distrik:Text;
        #seers:Text;
        #taggr:Text;
        #website:Text;
    };
}