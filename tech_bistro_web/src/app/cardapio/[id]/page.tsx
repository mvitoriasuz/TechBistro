import { createClient } from '@/lib/supabase';
import { Metadata, ResolvingMetadata } from 'next';
import { notFound } from 'next/navigation';
import { Utensils } from 'lucide-react';
import Image from 'next/image';

interface PageProps {
  params: { id: string };
}

interface Estabelecimento {
  cnpj: string;
  nome_estabelecimento: string;
}

interface Prato {
  id: number;
  nome_prato: string;
  valor_prato: number;
  categoria_prato: string;
  id_estabelecimento: string;
  descricao_prato?: string;
  imagem_url?: string | null;
}

interface CategoriaAgrupada {
  nome: string;
  pratos: Prato[];
}

export async function generateMetadata(
  { params }: PageProps,
  parent: ResolvingMetadata
): Promise<Metadata> {
  const supabase = createClient();
  const idDoEstabelecimento = params.id;

  const { data: estabelecimentoData, error } = await supabase
    .from('estabelecimentos')
    .select('nome_estabelecimento')
    .eq('cnpj', idDoEstabelecimento)
    .single();

  if (error || !estabelecimentoData) {
    return {
      title: 'Cardápio não encontrado | Techbistro',
    };
  }

  return {
    title: `${estabelecimentoData.nome_estabelecimento} - Cardápio Digital | Techbistro`,
  };
}

export default async function CardapioPage({ params }: PageProps) {
  const supabase = createClient();
  const idDoEstabelecimento = params.id;

  const { data: estabelecimento, error: estabelecimentoError } = await supabase
    .from('estabelecimentos')
    .select('cnpj, nome_estabelecimento')
    .eq('cnpj', idDoEstabelecimento)
    .single<Estabelecimento>();

  if (estabelecimentoError || !estabelecimento) {
    notFound();
  }

  const { data: pratos, error: pratosError } = await supabase
    .from('pratos')
    .select('id, nome_prato, valor_prato, categoria_prato, id_estabelecimento, descricao_prato, imagem_url')
    .eq('id_estabelecimento', idDoEstabelecimento);

  const listaDePratos = pratos ?? [];

  const categoriasAgrupadas: Record<string, Prato[]> = {};
  listaDePratos.forEach((prato) => {
    const categoriaNome = prato.categoria_prato || 'Outros';
    if (!categoriasAgrupadas[categoriaNome]) {
      categoriasAgrupadas[categoriaNome] = [];
    }
    categoriasAgrupadas[categoriaNome].push(prato);
  });

  const categoriasParaRenderizar: CategoriaAgrupada[] = Object.entries(categoriasAgrupadas)
    .map(([nome, pratos]) => ({ nome, pratos }))
    .sort((a, b) => a.nome.localeCompare(b.nome));

  return (
    <div className="min-h-screen bg-gradient-to-b from-[#510006] to-[#8C0010] font-sans selection:bg-[#C5A47E]/20">
      
      <header className="bg-[#510006] text-white py-4 sticky top-0 z-50 border-b border-[#C5A47E]/20 shadow-[0_2px_10px_rgba(0,0,0,0.15)]">
        <div className="container mx-auto px-5 max-w-3xl flex items-center justify-between">
          <Image
            src="/logo.svg"
            alt="Logo Techbistro"
            width={32}
            height={32}
            className="filter brightness-150"
          />
          
          <h1 className="text-xl font-semibold text-center tracking-wide uppercase">
            {estabelecimento.nome_estabelecimento}
          </h1>

          <div style={{ width: 32 }} />
        </div>
      </header>

      <main className="container mx-auto px-5 pt-6 pb-20 max-w-3xl">
        {categoriasParaRenderizar.length === 0 ? (
          <p className="text-center text-white/70 mt-16 text-lg">
            Nenhum item encontrado.
          </p>
        ) : (
          categoriasParaRenderizar.map((categoria) => (
            <section key={categoria.nome} className="mb-12">
              <div className="flex items-center gap-3 mb-5">
                <div className="h-[1px] flex-1 bg-[#C5A47E]/30"></div>
                <h2 className="text-sm font-medium text-[#C5A47E] tracking-[0.18em] uppercase">
                  {categoria.nome}
                </h2>
                <div className="h-[1px] flex-1 bg-[#C5A47E]/30"></div>
              </div>

              <div className="space-y-4">
                {categoria.pratos.map((prato) => (
                  
                  <div
                    key={prato.id}
                    className="bg-[#F7F4F0] p-4 rounded-xl border border-[#C5A47E]/20 shadow-sm hover:shadow-md hover:border-[#C5A47E]/40 transition-all duration-200"
                  >
                    <div className="flex items-start justify-between gap-4">
                      
                      <div className="flex items-start flex-grow gap-4">
                        
                        {/* LÓGICA DA IMAGEM ATUALIZADA:
                            Se tiver imagem_url, exibe a imagem.
                            Se não, exibe o ícone de talheres.
                            Aumentei para w-20 h-20 (80px) para a foto ficar visível.
                        */}
                        <div className="relative w-20 h-20 flex-shrink-0 rounded-lg overflow-hidden bg-gray-200">
                          {prato.imagem_url ? (
                            <Image
                              src={prato.imagem_url}
                              alt={prato.nome_prato}
                              fill
                              className="object-cover"
                              sizes="(max-width: 768px) 100vw, 33vw"
                            />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center bg-[#C5A47E]/15 text-[#6A0000]">
                              <Utensils size={24} strokeWidth={1.5} />
                            </div>
                          )}
                        </div>
                        
                        <div className="flex-grow">
                          <h3 className="text-[15px] font-semibold text-gray-900 tracking-wide leading-tight">
                            {prato.nome_prato}
                          </h3>
                          
                          {prato.descricao_prato && (
                            <p className="text-sm text-gray-600 leading-snug font-normal mt-1 line-clamp-3">
                              {prato.descricao_prato}
                            </p>
                          )}
                        </div>
                      </div>

                      <div className="flex-shrink-0 pt-1">
                        <p className="text-[15px] font-medium text-[#5A0000] whitespace-nowrap">
                          R$ {prato.valor_prato.toFixed(2).replace('.', ',')}
                        </p>
                      </div>

                    </div>
                  </div>
                ))}
              </div>
            </section>
          ))
        )}
      </main>
    </div>
  );
}