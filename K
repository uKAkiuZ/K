using UnityEngine;
public class CharaBase : MonoBehaviour
{
	//---------------------------------------------
	// 変数宣言
	//---------------------------------------------
	// キャラクタータイプ(種類)
	public enum CharaType
	{
		Player,             // プレイヤーキャラクタ
		Enemy0,             // エネミーキャラクタ
		Enemy1,             // エネミーキャラクタ
		PlayerAttack0,      // プレイヤーの攻撃
	}

	// コンディション(状態)
	public enum Condition
	{
		Normal,             // 通常時
		Damage,             // ダメージを受けている時
		Invincible,         // 無敵モード(Debugモードや特殊アイテム使用時等)時
		Dead,               // 死亡時
	}

	// 全てのキャラクターが持つ共通の情報群
	public bool isActive;               // 有効かどうか
	public int frame;                   // 作成されてからのフレーム数
	public Vector2 pos;                 // 座標
	public Vector2 speed;               // 移動速度
	public float jumpPower;             // ジャンプ力
	public float gravity;               // 重力
	public bool isGround;               // 着地フラグ
	public Rect colBody;                // 衝突判定(押し合い&攻撃&ダメージ)
	public Rect colFoot;                // 衝突判定(着地)
	public int iHP;                     // 体力
	public int power;                   // 攻撃力
	public Condition cndType;           // コンディション
	public int cndCnt;                  // コンディション更新カウンタ
	public CharaType type;              // キャラクターの種類

	//-----------------------------------------
	// 初期化(全キャラクター共通)
	//-----------------------------------------
	void Awake()
	{
		// デバッグ用短形生成
		DebugRect.CreateColRect(transform, colBody);
		DebugRect.CreateColRect(transform, colFoot);

		// 生成された時の座標を代入
		pos = transform.position;
	}

	//----------------------------------------
	// 更新処理(全キャラクター共通)
	//----------------------------------------
	public void UpdateChara()
	{
		// 実座標を更新する
		transform.position = pos;

		// 画面外に落下したらキャラを死亡させる
		if (pos.y < -100.0f)
		{
			cndType = Condition.Dead;
		}

		// コンディション更新
		if (cndType != Condition.Normal && cndType != Condition.Dead)
		{
			--cndCnt;
			if (cndCnt == 0)
			{
				cndType = Condition.Normal;
			}
		}

		// 生成されてからのフレーム数をカウントする
		++frame;
	}

	//--------------------------------------
	// ダメージ処理
	//--------------------------------------
	public void DamagePorc(int damage)
	{
		// HPを減らす
		iHP -= damage;

		// HPが0以下になったら死亡したことにする
		if (iHP <= 0)
		{
			cndType = Condition.Dead;
		}
		// HPがまだ残っていたら、一定時間無敵にさせる
		else
		{
			// キャラタイプから"プレイヤーの攻撃"を除外
			if (type != CharaType.PlayerAttack0)
			{
				cndType = Condition.Damage;
				cndCnt = 60;                    // 無敵時間を設定
			}
		}
	}

	//------------------------------------------------
	// キャラクターの左右移動(ブロックにめり込まない)
	// 戻り値：キャラがブロックに当たったらtrue
	//------------------------------------------------
	public bool MoveX()
	{
		bool isHit = false;				// 当たったかの戻り値
		Vector3 prevPos;				// 移動前座標
		float moveXVal = speed.x;       // 移動した量

		// Playerの左右移動の処理
		while (moveXVal != 0.0f)
		{
			// 移動前の座標を保存
			prevPos = pos;

			// 1ドット移動させる(移動量が1未満ならば移動量を無視して処理を抜ける)
			if (moveXVal <= -1.0f)
			{
				pos.x -= 1.0f;			// 移動
				moveXVal += 1.0f;		// 移動した量を減らす
			}
			// 1ドット移動させる(移動量が1未満ならば移動量を無視して処理を抜ける)
			else if (moveXVal >= 1.0f)
			{
				pos.x += 1.0f;			// 移動
				moveXVal -= 1.0f;		// 移動した量を減らす
			}
			// 移動量が1未満の時(処理を強制的に抜ける)
			else
			{
				break;
			}

			// 衝突するならば、移動をキャンセルして終了
			if (MyCollision.IsHitBlock(pos, colBody))
			{
				pos = prevPos;
				isHit = true;
				break;
			}
		}

		// 当たったかの判定を返す
		return isHit;
	}

	//---------------------------------------------------------------------------------------
	// プレイヤーの上下移動 (ブロックにめり込まない)
	// 戻り値：キャラがブロックに当たったらtrue
	//---------------------------------------------------------------------------------------
	public bool MoveY()
	{
		bool isHit = false;             // 当たったかの戻り値
		Vector3 prevPos;                // 移動前座標
		float moveYVal = speed.y;       // 移動した量

		// Playerの上下移動の処理
		while (moveYVal != 0.0f)
		{
			// 移動前の座標を保存
			prevPos = pos;

			// 1ドット移動させる(移動量が1未満ならば移動量を無視して処理を抜ける)
			if (moveYVal <= -1.0f)
			{
				pos.y -= 1.0f;          // 移動
				moveYVal += 1.0f;       // 移動した量を減らす
			}
			// 1ドット移動させる(移動量が1未満ならば移動量を無視して処理を抜ける)
			else if (moveYVal >= 1.0f)
			{
				pos.y += 1.0f;          // 移動
				moveYVal -= 1.0f;       // 移動した量を減らす
			}
			// 移動量が1未満の時(処理を強制的に抜ける)
			else
			{
				break;
			}

			// 衝突するならば、移動をキャンセルして終了
			if (MyCollision.IsHitBlock(pos, colBody))
			{
				pos = prevPos;
				isHit = true;
				break;
			}
		}

		// 当たったかの判定を返す
		return isHit;
	}
}
