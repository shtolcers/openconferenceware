require 'spec_helper'

describe SessionTypesController do
  include SessionTypesHelper
  fixtures :all

  before do
    @event = stub_current_event!(:event => events(:open))
    @session_type = Factory.create(:session_type, :event => @event)
  end
    
  describe "responding to GET index" do

    it "should redirect to the session types for the current event if none is given" do
      get :index
      response.should redirect_to(event_session_types_path(@event))
    end

    it "should expose all session_types from the current event as @session_types" do
      @event.should_receive(:session_types).and_return([@session_type])
      get :index, :event_id => @event.to_param
      assigns(:session_types).should == [@session_type]
    end

    describe "with mime type of xml" do
      it "should render all session_types from the current event as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        @event.should_receive(:session_types).and_return(session_types = double("Array of SessionTypes"))
        session_types.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    end
    
  end

  describe "responding to GET show" do

    it "should expose the requested session_type as @session_type" do
      SessionType.should_receive(:find).with("37").and_return(@session_type)
      get :show, :id => "37"
      assigns(:session_type).should equal(@session_type)
    end
    
    describe "with mime type of xml" do

      it "should render the requested session_type as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SessionType.should_receive(:find).with("37").and_return(@session_type)
        @session_type.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
    describe "with an invalid session type id" do
      it "should redirect to the session types index" do
        SessionType.should_receive(:find).with("invalid").and_raise(ActiveRecord::RecordNotFound)
        get :show, :id => "invalid"
        response.should redirect_to(event_session_types_path(events(:open)))
      end
    end
    
  end

  describe "as an admin" do
    before(:each) do
      login_as(:aaron)
    end

    describe "responding to GET new" do
      before do
        @new_session_type = SessionType.new
      end
    
      it "should expose a new session_type as @session_type" do
        SessionType.should_receive(:new).and_return(@new_session_type)
        get :new, :event => events(:open).slug
        assigns(:session_type).should equal(@new_session_type)
      end

    end

    describe "responding to GET edit" do
    
      it "should expose the requested session_type as @session_type" do
        SessionType.should_receive(:find).with("37").and_return(@session_type)
        get :edit, :id => "37"
        assigns(:session_type).should equal(@session_type)
      end

    end
  
    describe "responding to POST create" do
      before do
        @new_session_type = SessionType.new
      end

      describe "with valid params" do
        before do
          @valid_params = @session_type.attributes.slice(*SessionType.accessible_attributes(:admin)).clone
          @new_session_type.stub(:save).and_return(true)
        end
      
        it "should expose a newly created session_type as @session_type" do
          post :create, :session_type => @valid_params
          assigns(:session_type).attributes.slice(*SessionType.accessible_attributes(:admin)).should eq(@valid_params)
        end

        it "should redirect to the session types index" do
          SessionType.stub(:new).and_return(@new_session_type)
          post :create, :session_type => {}
          response.should redirect_to(event_session_types_path(@event))
        end
      
      end
    
      describe "with invalid params" do
        before do
          @new_session_type.stub(:save).and_return(false)
        end

        it "should expose a newly created but unsaved session_type as @session_type" do
          SessionType.stub(:new).and_return(@new_session_type)
          post :create, :session_type => {:title => 'hello'}
          assigns(:session_type).should equal(@new_session_type)
          assigns(:session_type).should be_new_record
        end

        it "should re-render the 'new' template" do
          SessionType.stub(:new).and_return(@new_session_type)
          post :create, :session_type => {}
          response.should render_template('new')
        end
      
      end
    
    end

    describe "responding to PUT update" do

      describe "with valid params" do
        before do
          @valid_params = Hash[@session_type.attributes.slice(*SessionType.accessible_attributes(:admin)).map{|k,v| [k,v.to_s]}]
          @session_type.stub(:save).and_return(true)
        end

        it "should update the requested session_type" do
          SessionType.should_receive(:find).with("37").and_return(@session_type)
          @session_type.should_receive(:assign_attributes).with(@valid_params, :as => :admin)
          put :update, :id => "37", :session_type => @valid_params
        end

        it "should expose the requested session_type as @session_type" do
          SessionType.stub(:find).and_return(@session_type)
          put :update, :id => "1"
          assigns(:session_type).should equal(@session_type)
        end

        it "should redirect to the session_type" do
          SessionType.stub(:find).and_return(@session_type)
          put :update, :id => "1"
          response.should redirect_to(session_type_path(@session_type))
        end

      end
    
      describe "with invalid params" do
        before do
          @session_type.stub(:save).and_return(false)
        end

        it "should update the requested session_type" do
          SessionType.should_receive(:find).with("37").and_return(@session_type)
          put :update, :id => "37", :session_type => {:title => 'hello'}
        end

        it "should expose the session_type as @session_type" do
          SessionType.stub(:find).and_return(@session_type)
          put :update, :id => "1"
          assigns(:session_type).should equal(@session_type)
        end

        it "should re-render the 'edit' template" do
          SessionType.stub(:find).and_return(@session_type)
          put :update, :id => "1"
          response.should render_template('edit')
        end

      end

    end

    describe "responding to DELETE destroy" do
      before do
        @session_type.stub(:destroy).and_return(true)
      end

      it "should destroy the requested session_type" do
        SessionType.should_receive(:find).with("37").and_return(@session_type)
        @session_type.should_receive(:destroy)
        delete :destroy, :id => "37"
      end
  
      it "should redirect to the session_types list" do
        SessionType.stub(:find).and_return(@session_type)
        delete :destroy, :id => "1"
        response.should redirect_to(event_session_types_path(@event))
      end

    end
  end

end
