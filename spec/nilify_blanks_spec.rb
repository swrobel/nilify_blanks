require "spec_helper"

describe NilifyBlanks do

  context "Model with nilify_blanks" do

    def array_supported?
      Post.content_columns.detect {|c| c.respond_to?(:array) && c.array?}
    end

    before(:all) do
      class Post < ActiveRecord::Base
        nilify_blanks
      end

      @post = Post.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0, :blog_id => '', :tags => [''])
      @post.save
    end

    it "should recognize all non-null string, text, citext columns" do
      Post.nilify_blanks_columns.should == ['first_name', 'title', 'summary', 'body', 'slug', 'blog_id', 'tags']
    end

    it "should convert all blanks to nils" do
      @post.first_name.should be_nil
      @post.title.should be_nil
      @post.summary.should be_nil
      @post.body.should be_nil
      @post.slug.should be_nil
      @post.blog_id.should be_nil
      @post.tags.should be_nil if array_supported?
    end

    it "should leave not-null last name field alone" do
      @post.last_name.should == ""
    end

    it "should leave integer views field alone" do
      @post.views.should == 0
    end

    it "should convert all array blanks to nils" do
      next unless array_supported?
      @post = Post.new(:last_name => '', :tags => ['', 'foo', nil, 'bar'])
      @post.save
      @post.tags.length.should == 2
    end

    it "should convert empty array to nil" do
      next unless array_supported?
      @post = Post.new(:last_name => '', :tags => ['', nil, ''])
      @post.save
      @post.tags.should == nil
    end
  end

  context "Model with nilify_blanks :nullables_only => false" do
    before(:all) do
      class PostWithNullables < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :nullables_only => false
      end

      @post = PostWithNullables.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0, :blog_id => '', :tags => [''])
    end

    it "should recognize all (even null) string, text, citext columns" do
      PostWithNullables.nilify_blanks_columns.should == ['first_name', 'last_name', 'title', 'summary', 'body', 'slug', 'blog_id', 'tags']
    end
  end

  context "Model with nilify_blanks :types => [:text]" do
    def citext_supported
      PostOnlyText.content_columns.detect {|c| c.type == :citext}
    end

    before(:all) do
      class PostOnlyText < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :types => [:text]
      end

      @post = PostOnlyText.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
      @post.save
    end

    it "should recognize all non-null text only columns" do
      expected_types = ['summary', 'body']
      expected_types << 'slug' unless citext_supported
      PostOnlyText.nilify_blanks_columns.should == expected_types
    end

    it "should convert all blanks to nils" do
      @post.summary.should be_nil
      @post.body.should be_nil
      @post.slug.should be_nil unless citext_supported
    end

    it "should leave not-null string fields alone" do
      @post.first_name.should == ""
      @post.last_name.should == ""
      @post.title.should == ""
      @post.slug.should == "" if citext_supported
    end
  end

  context "Model with nilify_blanks :types => [:hstore]" do
    def hstore_supported?
      PostOnlyHstore.content_columns.detect {|c| c.type == :hstore}
    end

    before(:all) do
      class PostOnlyHstore < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :types => [:hstore]
      end

      @post = PostOnlyHstore.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0, :custom_data => {:test => ''})
      @post.save
    end

    it "should convert all hstore blanks to nils" do
      next unless hstore_supported?
      @post = PostOnlyHstore.new(:last_name => '', :custom_data => {:test => '', :foo => 'bar', :yodawg => nil, :bar => 'foo'})
      @post.save
      @post.custom_data.length.should == 2
    end

    it "should convert empty hstore to nil" do
      next unless hstore_supported?
      @post = PostOnlyHstore.new(:last_name => '', :custom_data => {:test => '', :yodawg => nil})
      @post.save
      @post.custom_data.should == nil
    end
  end

  context "Model with nilify_blanks :only => [:first_name, :title]" do
    before(:all) do
      class PostOnlyFirstNameAndTitle < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :only => [:first_name, :title]
      end

      @post = PostOnlyFirstNameAndTitle.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
      @post.save
    end

    it "should recognize only first_name and title" do
      PostOnlyFirstNameAndTitle.nilify_blanks_columns.should == ['first_name', 'title']
    end

    it "should convert first_name and title blanks to nils" do
      @post.first_name.should be_nil
      @post.title.should be_nil
    end

    it "should leave other fields alone" do
      @post.summary.should == ""
      @post.body.should == ""
      @post.slug.should == ""
    end
  end

  context "Model with nilify_blanks :except => [:first_name, :title, :blog_id]" do
    def array_supported?
      Post.content_columns.detect {|c| c.respond_to?(:array) && c.array?}
    end

    before(:all) do
      class PostExceptFirstNameAndTitleAndBlogId < ActiveRecord::Base
        self.table_name = "posts"
        nilify_blanks :except => [:first_name, :title, :blog_id]
      end

      @post = PostExceptFirstNameAndTitleAndBlogId.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0, :tags => [''])
      @post.save
    end

    it "should recognize only summary, body, views, and tags" do
      PostExceptFirstNameAndTitleAndBlogId.nilify_blanks_columns.should == ['summary', 'body', 'slug', 'tags']
    end

    it "should convert summary, body, slug, and tags blanks to nils" do
      @post.summary.should be_nil
      @post.body.should be_nil
      @post.slug.should be_nil
      @post.tags.should be_nil if array_supported?
    end

    it "should leave other fields alone" do
      @post.first_name.should == ""
      @post.title.should == ""
    end
  end


  context "Global Usage" do
    context "Namespaced Base Class with nilify_blanks inline" do
      before(:all) do
        module Admin1
          class Base < ActiveRecord::Base
            self.abstract_class = true
            nilify_blanks
          end
        end

        class Admin1::Post < Admin1::Base
          self.table_name = "posts"
        end

        @post = Admin1::Post.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
        @post.save
      end

      it "should convert all blanks to nils" do
        @post.first_name.should be_nil
      end
    end

    context "Namespaced Base Class with nilify_blanks applied after definition" do
      before(:all) do
        module Admin2
          class Base < ActiveRecord::Base
            self.abstract_class = true
          end
        end

        class Admin2::Post < Admin2::Base
          self.table_name = "posts"
        end

        Admin2::Base.nilify_blanks

        @post = Admin2::Post.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
        @post.save
      end

      it "should convert all blanks to nils" do
        @post.first_name.should be_nil
      end
    end

    context "Namespaced Base Class with nilify_blanks applied after definition" do
      before(:all) do
        ActiveRecord::Base.nilify_blanks

        class InheritedPost < ActiveRecord::Base
          self.table_name = "posts"
        end

        @post = InheritedPost.new(:first_name => '', :last_name => '', :title => '', :summary => '', :body => '', :slug => '', :views => 0)
        @post.save
      end

      it "should convert all blanks to nils" do
        @post.first_name.should be_nil
      end
    end

  end
end
