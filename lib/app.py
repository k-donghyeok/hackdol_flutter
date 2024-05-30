from flask import Flask, request, jsonify
from transformers import BlenderbotTokenizer, BlenderbotForConditionalGeneration

# BlenderBot 2.0 모델과 토크나이저 로드
model_name = "facebook/blenderbot-400M-distill"
tokenizer = BlenderbotTokenizer.from_pretrained(model_name)
model = BlenderbotForConditionalGeneration.from_pretrained(model_name)

app = Flask(__name__)

def generate_response(input_text):
    # 입력 문장 토큰화
    inputs = tokenizer(input_text, return_tensors="pt")

    # 응답 생성
    reply_ids = model.generate(**inputs)
    
    # 응답 디코딩
    response = tokenizer.batch_decode(reply_ids, skip_special_tokens=True)[0]
    return response

@app.route('/chat', methods=['POST'])
def chat():
    user_input = request.json.get('message')
    response = generate_response(user_input)
    return jsonify({'response': response})

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5005)
