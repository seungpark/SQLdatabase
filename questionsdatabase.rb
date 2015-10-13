require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')

    self.results_as_hash = true
    self.type_translation = true
  end

  def get_first_result(*query_args)
    self.execute(*query_args)[0]
  end

end #end of class


class Question

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.get_first_result(<<-SQL,id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Question.new(result)
  end

  def self.find_by_author_id(author_id)
    results = QuestionsDatabase.instance.execute(<<-SQL,author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    results.map { |result| Question.new(result) }
  end

  attr_accessor :id, :title, :body, :author_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(author_id)
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

end


class User

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.get_first_result(<<-SQL,id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(result)
  end

  def self.find_by_name(fname, lname)
    result = QuestionsDatabase.instance.get_first_result(<<-SQL,fname,lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    User.new(result)
  end

  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end
end


class Reply

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.get_first_result(<<-SQL,id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    Reply.new(result)
  end

  def self.find_by_user_id(reply_author_id)
    results = QuestionsDatabase.instance.execute(<<-SQL,reply_author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        reply_author_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end

  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end

  def self.find_by_parent_id(parent_reply_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, parent_reply_id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  attr_accessor :id, :body, :question_id, :parent_reply_id, :reply_author_id

  def initialize(options = {})
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @reply_author_id = options['reply_author_id']
  end

  def author
    User.find_by_id(reply_author_id)
  end

  def question
    Question.find_by_id(question_id)
  end

  def parent_reply
    Reply.find_by_id(parent_reply_id)
  end

  def child_reply #one level deep
    Reply.find_by_parent_id(id)
  end

end

class QuestionFollow

#   QuestionFollow::followers_for_question_id(question_id)
# This will return an array of User objects!

  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        follower_id
      FROM
        question_follows
      INNER JOIN
        users
      ON
        question_follows.follower_id = users.id
      WHERE
        question_id = ?
    SQL

    results.map { |result| User.find_by_id(result["follower_id"]) }
  end

  def self.followed_questions_for_user_id(follower_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, follower_id)
      SELECT
        question_id
      FROM
        question_follows
      INNER JOIN
        questions
      ON
        question_follows.question_id = questions.id
      WHERE
        follower_id = ?
    SQL
    results.map { |result| Question.find_by_id(result["question_id"]) }
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        question_id
      FROM
        question_follows
      GROUP BY
        question_id
      ORDER BY
        COUNT(follower_id) DESC
      LIMIT
        ?
    SQL
    results.map { |result| Question.find_by_id(result["question_id"])}
  end

  attr_accessor :follower_id, :question_id

  def initialize(options = {})
    @follower_id = options['follower_id']
    @question_id = options['question_id']
  end

end


class QuestionLike

  def self.likers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL
    results.map { |result| QuestionLike.new(result) }
  end

  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        user_id = ?
    SQL
    results.map { |result| QuestionLike.new(result) }
  end

  attr_accessor :user_id, :question_id

  def initialize(options = {})
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end
