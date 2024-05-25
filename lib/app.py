from flask import Flask, request, jsonify

app = Flask(__name__)

def get_response(question):
    question = question.lower()
    if '안녕' in question:
        return "안녕하세요! 무엇을 도와드릴까요?"
    elif '날씨' in question:
        return "오늘 날씨는 맑습니다. 외출하기 좋은 날이에요!"
    elif '이름' in question:
        return "저는 AI 챗봇입니다. 이름이 없어요."
    else:
        return "죄송해요, 이해하지 못했어요. 다른 질문을 해주시겠어요?"

@app.route('/chatbot', methods=['POST'])
def chatbot():
    data = request.get_json()
    question = data['question']
    response = get_response(question)
    return jsonify({'response': response})

if __name__ == '__main__':
    app.run(host='192.168.35.3', port=5000)
